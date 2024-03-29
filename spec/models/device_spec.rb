# == Schema Information
#
# Table name: devices
#
#  id           :bigint           not null, primary key
#  device_token :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  device_id    :string
#  user_id      :bigint           not null
#
require 'rails_helper'

RSpec.describe Device, type: :model do
  describe 'ActiveRecord specification' do
    it { is_expected.to have_db_column(:id).of_type(:integer) }
    it { is_expected.to have_db_column(:device_id).of_type(:string) }
    it { is_expected.to have_db_column(:device_token).of_type(:string) }
  end

  describe 'Active record validation' do
    it { is_expected.to validate_presence_of(:device_token) }
    it { is_expected.to belong_to(:user) }
  end
end
