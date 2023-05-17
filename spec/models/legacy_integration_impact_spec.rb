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
require 'rails_helper'

RSpec.describe LegacyIntegrationImpact, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
