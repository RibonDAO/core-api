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

  scope :with_fees_balance, -> { where('fees_balance_cents > 0') }
end
