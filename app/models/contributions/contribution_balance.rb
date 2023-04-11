# == Schema Information
#
# Table name: contribution_balances
#
#  id                         :bigint           not null, primary key
#  fees_balance_cents         :integer
#  tickets_balance_cents      :integer
#  total_fees_increased_cents :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  contribution_id            :bigint           not null
#
class ContributionBalance < ApplicationRecord
  belongs_to :contribution

  validates :tickets_balance_cents, :fees_balance_cents, :total_fees_increased_cents, presence: true

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
end
