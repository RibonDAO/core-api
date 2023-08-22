# == Schema Information
#
# Table name: contributions
#
#  id                  :bigint           not null, primary key
#  generated_fee_cents :integer
#  receiver_type       :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  person_payment_id   :bigint           not null
#  receiver_id         :bigint           not null
#
class Contribution < ApplicationRecord
  # TODO: remove receiver - already exists in person_payment
  belongs_to :receiver, polymorphic: true
  belongs_to :person_payment
  has_one :contribution_balance
  has_many :donation_contributions
  has_many :donations, through: :donation_contributions
  has_many :users, through: :donations
  has_many :contribution_fees

  delegate :liquid_value_cents, to: :person_payment
  delegate :usd_value_cents, to: :person_payment
  delegate :from_big_donor?, to: :person_payment
  delegate :from_customer?, to: :person_payment

  scope :with_tickets_balance_higher_than, lambda { |amount = 0|
                                             joins(:contribution_balance)
                                               .where('contribution_balances.tickets_balance_cents >= ?', amount)
                                           }
  scope :with_fees_balance_higher_than, lambda { |amount = 0|
    joins(:contribution_balance)
      .where('contribution_balances.fees_balance_cents >= ?', amount)
  }
  scope :from_unique_donors, lambda {
                               joins(:person_payment)
                                 .where('person_payments.payer_type IN (?, ?)', 'Customer', 'CryptoUser')
                             }
  scope :from_big_donors, -> { joins(:person_payment).where(person_payments: { payer_type: 'BigDonor' }) }
  scope :ordered_by_donation_contribution, lambda {
    joins(
      "LEFT OUTER JOIN (
            SELECT MAX(created_at) AS last_donation_created_at, contribution_id
            FROM donation_contributions
            GROUP BY contribution_id
          ) AS last_donations ON contributions.id = last_donations.contribution_id"
    ).order('last_donations.last_donation_created_at DESC NULLS LAST')
  }

  scope :with_tickets_balance_less_than_10_percent, lambda {
    joins(:contribution_balance)
      .joins(:person_payment)
      .where('contribution_balances.tickets_balance_cents <= 0.1 * person_payments.usd_value_cents')
  }
  scope :with_paid_status, lambda {
    joins(:person_payment).where(person_payments: { status: :paid })
  }
  scope :with_payment_in_blockchain, lambda {
    joins(person_payment: :person_blockchain_transactions)
      .where(person_blockchain_transactions: { treasure_entry_status: :success })
  }
  scope :with_cause_receiver, lambda {
    where(receiver_type: 'Cause')
  }
  scope :created_before, ->(date) { where('created_at < ?', date) }

  def set_contribution_balance
    return unless contribution_balance.nil?
    return if receiver_type == 'NonProfit'

    fee_percentage = RibonConfig.contribution_fee_percentage
    fees_balance_cents = (usd_value_cents * (fee_percentage / 100.0)).round
    tickets_balance_cents = usd_value_cents - fees_balance_cents

    create_contribution_balance!(contribution_increased_amount_cents: 0,
                                 tickets_balance_cents:, fees_balance_cents:)
  rescue StandardError => e
    Reporter.log(error: e)
  end

  def already_spread_fees?
    contribution_fees.any?
  end

  def label
    "#{receiver&.name} (#{created_at.strftime('%b/%Y')})"
  end

  def non_profits
    return [receiver] if receiver_type == 'NonProfit'

    receiver&.non_profits
  end
end
