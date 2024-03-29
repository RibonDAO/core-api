# == Schema Information
#
# Table name: accounts
#
#  id           :bigint           not null, primary key
#  confirmed_at :datetime
#  deleted_at   :datetime
#  platform     :string
#  provider     :string
#  tokens       :json
#  uid          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe '.validations' do
    subject { build(:account) }

    it { is_expected.to validate_presence_of(:uid) }
  end
end
