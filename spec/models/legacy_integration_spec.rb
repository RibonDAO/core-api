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
require 'rails_helper'

RSpec.describe LegacyIntegration, type: :model do
  describe '.validations' do
    subject { build(:legacy_integration) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:legacy_id) }
    it { is_expected.to belong_to(:integration).optional }
  end
end
