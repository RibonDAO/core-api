# frozen_string_literal: true

require 'rails_helper'

describe Manager::AuthenticateManagerByPassword do
  let(:command) { described_class.call(email: manager.email, password:) }
  let(:manager) { create(:user_manager, password: '123456') }

  describe '.call' do
    context 'when the password is valid' do
      let(:password) { '123456' }

      it 'returns successs' do
        expect(command).to be_success
      end

      it 'returns the access and refresh tokens' do
        expect(command.result).to include(:access_token, :refresh_token)
      end
    end

    context 'when the password is invalid' do
      let(:password) { '654321' }

      it 'returns failure' do
        expect(command).to be_failure
      end

      it 'does not return the access and refresh tokens' do
        expect(command.result).to be_nil
      end
    end
  end
end
