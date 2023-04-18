# == Schema Information
#
# Table name: contribution_fees
#
#  id                                        :bigint           not null, primary key
#  fee_cents                                 :integer
#  payer_contribution_increased_amount_cents :integer
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  contribution_id                           :bigint           not null
#  payer_contribution_id                     :bigint           not null
#
class ContributionFee < ApplicationRecord
  belongs_to :contribution
  belongs_to :payer_contribution, class_name: 'Contribution'
end
