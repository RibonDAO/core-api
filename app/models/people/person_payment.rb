# == Schema Information
#
# Table name: person_payments
#
#  id             :bigint           not null, primary key
#  amount_cents   :integer
#  currency       :integer
#  error_code     :string
#  paid_date      :datetime
#  payment_method :integer
#  receiver_type  :string
#  refund_date    :datetime
#  status         :integer          default("processing")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  external_id    :string
#  integration_id :bigint
#  offer_id       :bigint
#  person_id      :uuid
#  receiver_id    :bigint
#
class PersonPayment < ApplicationRecord
  include UuidHelper

  before_create :set_currency
  after_create :set_fees

  belongs_to :person
  belongs_to :integration
  belongs_to :offer, optional: true
  belongs_to :receiver, polymorphic: true, optional: true

  has_many :person_blockchain_transactions
  has_one :person_payment_fee

  validates :paid_date, :status, :payment_method, presence: true

  enum status: {
    processing: 0,
    paid: 1,
    failed: 2,
    refunded: 3,
    refund_failed: 4
  }

  enum payment_method: {
    credit_card: 0,
    pix: 1,
    crypto: 2
  }

  enum currency: {
    brl: 0,
    usd: 1
  }

  def crypto_amount
    amount_with_fees = amount - service_fees
    return amount_with_fees if currency&.to_sym == :usd

    Currency::Converters.convert_to_usd(value: amount_with_fees, from: currency&.to_sym).round.to_f
  end

  def amount
    return amount_value if amount_cents

    offer&.price_value
  end

  def amount_value
    amount_cents / 100.0
  end

  def set_fees
    fees = Givings::Card::CalculateCardGiving.call(value: amount_value, currency: currency&.to_sym).result
    create_person_payment_fee!(card_fee_cents: fees[:card_fee].cents,
                               crypto_fee_cents: fees[:crypto_fee].cents)
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

  private

  def set_currency
    self.currency = offer&.currency || :usd
  end
end
