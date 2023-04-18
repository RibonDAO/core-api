# == Schema Information
#
# Table name: legacy_non_profits
#
#  id                 :bigint           not null, primary key
#  cost_of_one_impact :integer
#  impact_description :string
#  logo_url           :string
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  current_id         :integer
#  legacy_id          :integer
#
FactoryBot.define do
  factory :legacy_non_profit do
    name { 'NonProfit' }
    logo_url { 'https://google.com' }
    cost_of_one_impact { 1 }
    impact_description { '1 impact for NonProfit' }
    legacy_id { 1 }
    current_id { 1 }
  end
end
