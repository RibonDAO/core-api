# frozen_string_literal: true

require 'rails_helper'

describe Auth::Accounts::AuthorizeOtpCode do
  describe '.call' do
    subject(:command) { described_class.call(otp_code:, authenticatable:) }

    let(:authenticatable) { create(:big_donor) }
    let(:otp_code) { 'RIB0N' }
    let(:otp_code_service) { instance_double(Auth::OtpCodeService, valid_otp_code?: valid_otp) }
  
    before(:each) do
      allow(Auth::OtpCodeService).to receive(:new).and_return(otp_code_service)
      allow(Jwt::Auth::Issuer).to receive(:call).and_return(%w[access_token refresh_token])
    end

    context 'when the OTP is valid' do
      let(:valid_otp) { true }

      it 'return success' do
        expect(command).to be_success
      end

      it 'return an access token and refresh token for the authenticatable' do
        expect(command.result).to eq(%w[access_token refresh_token])
      end
    end

    context 'when the OTP is not valid' do
      let(:valid_otp) { false }

      it 'returns failure' do
        expect(command).to be_failure
      end
    end
  end
end
