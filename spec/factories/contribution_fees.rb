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
FactoryBot.define do
  factory :contribution_fee do
    association :contribution, factory: :contribution
    payer_contribution { build(:contribution) }
    fee_cents { 1 }
  end
end
