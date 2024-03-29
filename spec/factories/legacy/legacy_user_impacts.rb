# == Schema Information
#
# Table name: legacy_user_impacts
#
#  id                   :bigint           not null, primary key
#  donations_count      :integer
#  total_donated_usd    :decimal(, )
#  total_impact         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  legacy_non_profit_id :bigint           not null
#  user_id              :bigint           not null
#
FactoryBot.define do
  factory :legacy_user_impact do
    legacy_non_profit { build(:legacy_non_profit) }
    total_impact { '1 food donated' }
    total_donated_usd { 1 }
    donations_count { 1 }
  end
end
