require 'rails_helper'

RSpec.describe Auth::OtpCodeService, type: :service do
  subject(:service) { described_class.new(authenticatable:) }

  let(:authenticatable) { create(:account) }

  describe '#create_otp_code' do
    it 'returns a new OTP code' do
      expect(service.create_otp_code).to match(/\A\d{6}\z/)
    end
  end

  describe '#valid_otp_code?' do
    let(:otp_code) { '123456' }

    context 'when the OTP is valid and exists on Redis' do
      before do
        allow(SecureRandom).to receive(:random_number).and_return(otp_code)
        service.send(:create_otp_code)
      end

      it 'returns true' do
        expect(service.valid_otp_code?(otp_code)).to be_truthy
      end

      it 'remove the OTP code from Redis after use' do
        service.valid_otp_code?(otp_code)
        expect(service.send(:current_otp_code)).to be_nil
      end

      context 'when the OTP is different from passed argument' do
        it 'returns false' do
          expect(service.valid_otp_code?('000000')).to be_falsey
        end
      end
    end

    context 'when the OTP does not exist or is expired' do
      it 'returns false' do
        expect(service.valid_otp_code?('000001')).to be_falsey
      end
    end
  end
end
