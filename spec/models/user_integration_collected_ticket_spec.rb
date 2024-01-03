# == Schema Information
#
# Table name: user_integration_collected_tickets
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  integration_id :bigint           not null
#  user_id        :bigint           not null
#
require 'rails_helper'

RSpec.describe UserIntegrationCollectedTicket, type: :model do
  describe '.validations' do
    subject { build(:user_integration_collected_ticket) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:integration) }
  end
end
