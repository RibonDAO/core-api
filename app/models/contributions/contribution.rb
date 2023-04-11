# == Schema Information
#
# Table name: contributions
#
#  id                :bigint           not null, primary key
#  receiver_type     :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  person_payment_id :bigint           not null
#  receiver_id       :bigint           not null
#
class Contribution < ApplicationRecord
  # TODO: remove receiver - already exists in person_payment
  belongs_to :receiver, polymorphic: true
  belongs_to :person_payment
  has_one :contribution_balance
  has_many :donation_contributions
  has_many :contribution_fees

  delegate :liquid_value_cents, to: :person_payment
  delegate :usd_value_cents, to: :person_payment
  delegate :from_big_donor?, to: :person_payment
  delegate :from_customer?, to: :person_payment

  scope :with_tickets_balance_higher_than, lambda { |amount = 0|
                                             joins(:contribution_balance)
                                               .where('contribution_balances.tickets_balance_cents >= ?', amount)
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

  def set_contribution_balance
    return unless contribution_balance.nil?

    fee_percentage = RibonConfig.contribution_fee_percentage
    tickets_balance_cents = usd_value_cents * (100 - fee_percentage) / 100
    fees_balance_cents = usd_value_cents * (fee_percentage / 100)

    create_contribution_balance!(
      total_fees_increased_cents: 0,
      tickets_balance_cents:,
      fees_balance_cents:
    )
  rescue StandardError => e
    Reporter.log(error: e)
  end
end
