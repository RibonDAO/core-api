# == Schema Information
#
# Table name: legacy_integration_impacts
#
#  id                      :bigint           not null, primary key
#  donations_count         :integer
#  donors_count            :integer
#  reference_date          :date
#  total_donated_usd_cents :integer
#  total_impact            :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  legacy_integration_id   :bigint
#  legacy_non_profit_id    :bigint
#
FactoryBot.define do
  factory :legacy_integration_impact do
    legacy_integration { nil }
    legacy_non_profit { nil }
    total_donated_usd_cents { 1 }
    total_impact { '10 days of water' }
    donations_count { 1 }
    donors_count { 1 }
    reference_date { '2023-05-17' }
  end
end
