# == Schema Information
#
# Table name: plans
#
#  id              :bigint           not null, primary key
#  daily_tickets   :integer
#  monthly_tickets :integer
#  status          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  offer_id        :bigint           not null
#
require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe '.validations' do
    subject { build(:plan) }

    it { is_expected.to validate_presence_of(:daily_tickets) }
    it { is_expected.to validate_presence_of(:monthly_tickets) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to belong_to(:offer) }
  end
end
