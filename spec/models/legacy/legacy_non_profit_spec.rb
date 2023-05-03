# == Schema Information
#
# Table name: legacy_non_profits
#
#  id                 :bigint           not null, primary key
#  impact_cost_ribons :integer
#  impact_cost_usd    :decimal(, )
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
    it { is_expected.to validate_presence_of(:impact_cost_ribons) }
    it { is_expected.to validate_presence_of(:impact_cost_usd) }
    it { is_expected.to validate_presence_of(:impact_description) }
    it { is_expected.to validate_presence_of(:legacy_id) }
  end
end
