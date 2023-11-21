# == Schema Information
#
# Table name: accounts
#
#  id                   :bigint           not null, primary key
#  confirmation_sent_at :datetime
#  confirmation_token   :string
#  confirmed_at         :datetime
#  deleted_at           :datetime
#  image                :string
#  name                 :string
#  nickname             :string
#  provider             :string
#  remember_created_at  :datetime
#  tokens               :json
#  uid                  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :bigint           not null
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

  describe '#create_user_for_provider' do
    let(:data) do
      OpenStruct.new(email: 'user1@ribon.io')
    end
    let(:provider) { 'google_oauth2' }

    it 'creates the User for google' do
      expect { described_class.create_user_for_provider(data, provider) }.to change(described_class, :count).by(1)
    end

    context 'when creating a new user with the correct params' do
      let(:account) { described_class.create_user_for_provider(data, provider) }

      it 'sets the email correctly' do
        expect(account.email).to eq('user1@ribon.io')
      end

      it 'sets the provider correctly' do
        expect(account.provider).to eq('google_oauth2')
      end
    end
  end

  describe '#create_user_for_magic_link' do
    let(:email) { 'user1@ribon.io' }
    let(:provider) { 'magic_link' }

    it 'creates the user account from magic link' do
      expect { described_class.create_user_for_provider(email, provider) }.to change(described_class, :count).by(1)
    end

    context 'when creating a new user with the correct params' do
      let(:account) { described_class.create_user_for_provider(email, provider) }

      it 'sets the email correctly' do
        expect(account.email).to eq('user1@ribon.io')
      end

      it 'sets the provider correctly' do
        expect(account.provider).to eq('magic_link')
      end
    end
  end
end
