# == Schema Information
#
# Table name: tickets
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  external_id    :string
#  integration_id :bigint           not null
#  user_id        :bigint           not null
#
require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe '.validations' do
    subject { build(:ticket) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:integration) }
  end
end
