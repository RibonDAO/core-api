# frozen_string_literal: true

require 'rails_helper'

describe Users::Anonymize do
  describe '.call' do
    subject(:command) { described_class.call(user) }

    let(:user) { create(:user, id: 12) }

    it 'updates the user email' do
      command
      expect(user.reload.email).to eq('deleted_user+12@ribon.io')
    end

    context 'when there is a user profile' do
      let(:user_profile) { create(:user_profile, user:) }

      it 'destroy the user profile' do
        expect { command }.to change(UserProfile, :count).by(0)
      end
    end

    context 'when the user has an account' do
      let(:account) { create(:account, user:) }

      before do
        account
      end

      it 'updates the account uid' do
        command
        expect(account.reload.uid).to eq('deleted_user+12@ribon.io')
      end
    end
  end
end
