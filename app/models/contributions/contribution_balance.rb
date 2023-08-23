# == Schema Information
#
# Table name: contribution_balances
#
#  id                                  :bigint           not null, primary key
#  contribution_increased_amount_cents :integer
#  fees_balance_cents                  :integer
#  tickets_balance_cents               :integer
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  contribution_id                     :bigint           not null
#
class ContributionBalance < ApplicationRecord
  belongs_to :contribution

  validates :tickets_balance_cents, :fees_balance_cents, :contribution_increased_amount_cents, presence: true

  scope :total_tickets_balance_from_big_donors, lambda {
                                                  joins(contribution: :person_payment)
                                                    .where(person_payments: { payer_type: 'BigDonor' })
                                                    .sum(:tickets_balance_cents)
                                                }

  scope :total_tickets_balance_from_unique_donors, lambda {
                                                     joins(contribution: :person_payment)
                                                       .where(person_payments: { payer_type: 'Customer' })
                                                       .sum(:tickets_balance_cents)
                                                   }

  scope :with_paid_status, lambda {
    joins(contribution: :person_payment)
      .where(person_payments: { status: :paid })
  }
  scope :with_payment_in_blockchain, lambda {
    joins(contribution: { person_payment: :person_blockchain_transactions })
      .where(person_blockchain_transactions: { treasure_entry_status: :success })
  }

  scope :with_fees_balance, -> { where('fees_balance_cents > 0') }
  scope :with_tickets_balance, -> { where('tickets_balance_cents > 0') }
  scope :created_before, ->(date) { where('contribution_balances.created_at < ?', date) }
  scope :confirmed_on_blockchain_before, lambda { |date|
    joins(contribution: { person_payment: :person_blockchain_transactions })
      .where(person_blockchain_transactions: { succeeded_at: ..date }).distinct
  }

  def enough_tickets_balance?(amount)
    tickets_balance_cents >= amount
  end

  def remaining_total_cents
    tickets_balance_cents + fees_balance_cents
  end
end
