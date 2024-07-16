# frozen_string_literal: true

require 'rails_helper'

describe Auth::SendOtpCode do
  describe '.call' do
    subject(:command) { described_class.call(authenticatable:) }

    let(:authenticatable) { create(:big_donor) }
    let(:otp_code_service) { instance_double(Auth::OtpCodeService, find_or_create_otp_code: otp_code) }
    let(:otp_code) { 'R1b0n' }

    let(:event) do
      OpenStruct.new({
                       name: 'send_otp_code',
                       data: {
                         email: authenticatable.email,
                         code: otp_code
                       }
                     })
    end

    before do
      allow(EventServices::SendEvent).to receive(:new)
      allow(Auth::OtpCodeService).to receive(:new).and_return(otp_code_service)
    end

    it 'sends an email with the OTP code with correct params' do
      command

      expect(EventServices::SendEvent).to have_received(:new).with(
        user: authenticatable,
        event:
      )
    end
  end
end
