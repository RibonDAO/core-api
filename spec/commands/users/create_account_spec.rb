# frozen_string_literal: true

require 'rails_helper'

describe Users::CreateAccount do
  describe '.call' do
    %w[google_oauth2 google_oauth2_access apple].each do |provider|
      context "when #{provider}" do
        let(:data) do
          OpenStruct.new(email: 'user1@ribon.io')
        end
        let(:command) { described_class.call(data:, provider:) }

        it 'creates the account for google' do
          expect { command }.to change(Account, :count).by(1)
        end

        context 'when creating a new user with the correct params' do
          it 'sets the email correctly' do
            account = command.result
            expect(account.email).to eq('user1@ribon.io')
          end

          it 'sets the provider correctly' do
            account = command.result
            expect(account.provider).to eq(provider)
          end
        end
      end
    end
  end
end
