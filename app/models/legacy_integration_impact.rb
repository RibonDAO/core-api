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
class LegacyIntegrationImpact < ApplicationRecord
  belongs_to :legacy_integration
  belongs_to :legacy_non_profit
end
