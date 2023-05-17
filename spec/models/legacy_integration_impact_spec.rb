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
  describe '.validations' do
    subject { build(:legacy_integration_impact) }

    it { is_expected.to belong_to(:legacy_integration) }
    it { is_expected.to belong_to(:legacy_non_profit) }
    it { is_expected.to validate_presence_of(:reference_date) }
    it { is_expected.to validate_presence_of(:donations_count) }
    it { is_expected.to validate_presence_of(:donors_count) }
    it { is_expected.to validate_presence_of(:total_donated_usd_cents) }
    it { is_expected.to validate_presence_of(:total_impact) }
  end
end
