# rubocop:disable Metrics/ClassLength
# == Schema Information
#
# Table name: person_payments
#
#  id                   :bigint           not null, primary key
#  amount_cents         :integer
#  currency             :integer
#  error_code           :string
#  liquid_value_cents   :integer
#  paid_date            :datetime
#  payer_type           :string
#  payment_method       :integer
#  platform             :string
#  receiver_type        :string
#  refund_date          :datetime
#  ribon_club_fee_cents :integer
#  status               :integer          default("processing")
#  usd_value_cents      :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  external_id          :string
#  external_invoice_id  :string
#  integration_id       :bigint
#  offer_id             :bigint
#  payer_id             :uuid
#  receiver_id          :bigint
#  subscription_id      :bigint
#
class PersonPayment < ApplicationRecord
  include UuidHelper

  before_create :set_currency
  before_create :set_ribon_club_fee_cents
  after_create :set_fees
  after_create :set_liquid_value_cents
  after_create :set_usd_value_cents

  belongs_to :integration
  belongs_to :offer, optional: true
  belongs_to :receiver, polymorphic: true, optional: true
  belongs_to :payer, polymorphic: true
  belongs_to :subscription, optional: true

  has_many :person_blockchain_transactions
  has_one :person_payment_fee
  has_one :contribution
  has_one :utm, as: :trackable

  validates :paid_date, :status, :payment_method, presence: true

  scope :without_contribution, -> { where.missing(:contribution) }

  enum status: {
    processing: 0, paid: 1, failed: 2, refunded: 3,
    refund_failed: 4, requires_action: 5, blocked: 6,
    requires_confirmation: 7
  }

  enum payment_method: {
    credit_card: 0,
    pix: 1,
    crypto: 2,
    google_pay: 3,
    apple_pay: 4
  }

  enum currency: {
    brl: 0,
    usd: 1
  }

  def from_big_donor? = payer_type == 'BigDonor'

  def from_customer? = payer_type == 'Customer'

  def amount
    return amount_value if amount_cents

    offer&.price_value
  end

  def amount_value
    amount_cents / 100.0
  end

  def formatted_amount
    Money.from_cents(amount_cents, currency).format
  end

  def crypto_amount
    (usd_value_cents.to_i / 100.0).round(2).to_f
  end

  def set_fees
    return create_person_payment_fee!(card_fee_cents: 0, crypto_fee_cents: 0) if crypto?

    fees = Givings::Card::CalculateCardGiving
           .call(value: amount_value, currency: currency&.to_sym, gateway:).result
    create_person_payment_fee!(card_fee_cents: fees[:card_fee].cents, crypto_fee_cents: fees[:crypto_fee].cents)
  rescue StandardError => e
    Reporter.log(error: e)
  end

  def set_liquid_value_cents
    self.liquid_value_cents = amount_cents - person_payment_fee&.service_fee_cents.to_i - ribon_club_fee_cents.to_i
    save!
  rescue StandardError => e
    Reporter.log(error: e)
  end

  def set_usd_value_cents
    if currency&.to_sym == :usd
      self.usd_value_cents = liquid_value_cents
    else
      self.usd_value_cents = Currency::Converters.convert_to_usd(value: liquid_value_cents,
                                                                 from: currency&.to_sym).round.to_f
    end
    save!
  rescue StandardError => e
    Reporter.log(error: e)
  end

  def pool
    case receiver_type
    when 'Cause'
      receiver.default_pool
    when 'NonProfit'
      receiver.cause.default_pool
    end
  end

  def person_blockchain_transaction
    person_blockchain_transactions.last
  end

  def create_person_blockchain_transaction(treasure_entry_status:, transaction_hash:)
    person_blockchain_transactions.create(treasure_entry_status:, transaction_hash:)
  end

  def service_fees
    person_payment_fee&.service_fee || 0
  end

  def payer_identification
    payer&.identification
  end

  def set_ribon_club_fee_cents
    return self.ribon_club_fee_cents = 0 unless club?

    self.ribon_club_fee_cents = (amount_cents.to_i * (RibonConfig.ribon_club_fee_percentage.to_i / 100.0)).round
  end

  private

  def club?
    subscription&.active? && offer&.category == 'club'
  end

  def set_currency
    self.currency = offer&.currency || :usd
  end

  def gateway
    @gateway ||= offer&.gateway&.downcase&.to_sym || :stripe
  end
end

# rubocop:enable Metrics/ClassLength
