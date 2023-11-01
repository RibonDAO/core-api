# == Schema Information
#
# Table name: accounts
#
#  id                     :bigint           not null, primary key
#  allow_password_change  :boolean
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  encrypted_password     :string
#  image                  :string
#  name                   :string
#  nickname               :string
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :json
#  uid                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :bigint           not null
#
# spec/models/account_spec.rb
require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe '.validations' do
    subject { build(:account) }

    it { is_expected.to validate_presence_of(:uid) }
  end

  describe '#create_user_for_provider(google)' do
    let(:data) do
      OpenStruct.new(email: 'user1@ribon.io', provider: 'google_oauth2')
    end

    it 'creates the Account from google' do
      expect { described_class.create_user_for_provider(data, 'google_oauth2') }
        .to change(described_class, :count).by(1)
    end

    context 'when creating a new user with the correct params' do
      let(:account) { described_class.create_user_for_provider(data, 'google_oauth2') }

      it 'sets the email correctly' do
        expect(account.email).to eq('user1@ribon.io')
      end

      it 'sets the provider correctly' do
        expect(account.provider).to eq('google_oauth2')
      end
    end
  end
end
