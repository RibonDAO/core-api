# == Schema Information
#
# Table name: refresh_tokens
#
#  id                   :bigint           not null, primary key
#  authenticatable_type :string           not null
#  crypted_token        :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  authenticatable_id   :string           not null
#
require 'rails_helper'

RSpec.describe RefreshToken, type: :model do
  describe '.validations' do
    subject { build(:refresh_token) }

    it { is_expected.to belong_to(:authenticatable) }
  end

  describe '.find_by_token' do
    let(:user_manager) { create(:user_manager) }

    it 'finds the user by the cripted token' do
      refresh_token = user_manager.refresh_tokens.create!
      token = refresh_token.token

      expect(described_class.find_by_token(token)).to eq refresh_token
    end
  end
end
