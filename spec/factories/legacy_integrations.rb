# == Schema Information
#
# Table name: legacy_integrations
#
#  id             :bigint           not null, primary key
#  name           :string
#  total_donors   :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  integration_id :bigint
#  legacy_id      :bigint
#
FactoryBot.define do
  factory :legacy_integration do
    name { 'Qulture Rocks' }
    integration { build(:integration) }
    total_donors { 1 }
    legacy_id { 1 }
  end
end
