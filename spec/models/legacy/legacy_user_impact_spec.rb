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
require 'rails_helper'

RSpec.describe LegacyUserImpact, type: :model do
  describe '.validations' do
    subject { build(:legacy_user_impact) }

    it { is_expected.to belong_to(:legacy_user) }
    it { is_expected.to belong_to(:legacy_non_profit).optional }
    it { is_expected.to validate_presence_of(:total_impact) }
    it { is_expected.to validate_presence_of(:donations_count) }
    it { is_expected.to validate_presence_of(:user_email) }
    it { is_expected.to validate_presence_of(:user_legacy_id) }
    it { is_expected.to validate_presence_of(:user_created_at) }
  end
end
