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
require 'rails_helper'

RSpec.describe LegacyNonProfit, type: :model do
  describe '.validations' do
    subject { build(:legacy_non_profit) }

    it { is_expected.to have_many(:legacy_user_impacts) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:logo_url) }
    it { is_expected.to validate_presence_of(:cost_of_one_impact) }
    it { is_expected.to validate_presence_of(:impact_description) }
    it { is_expected.to validate_presence_of(:legacy_id) }
  end
end
