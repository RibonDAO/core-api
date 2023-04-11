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
FactoryBot.define do
  factory :contribution_balance do
    contribution { build(:contribution) }
    tickets_balance_cents { 100 }
    fees_balance_cents { 100 }
    total_fees_increased_cents { 100 }

    trait :with_paid_status do
      before(:create) do |contribution_balance|
        contribution_balance.contribution = create(:contribution, :with_paid_status)
      end
    end
  end
end
