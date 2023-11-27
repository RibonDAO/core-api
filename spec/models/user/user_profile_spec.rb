# == Schema Information
#
# Table name: user_profiles
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
require 'rails_helper'

RSpec.describe UserProfile, type: :model do
  describe '.validations' do
    subject(:user_profile) { build(:user_profile) }

    it { is_expected.to belong_to(:user) }
  end
end
