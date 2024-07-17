require 'rails_helper'

RSpec.describe Auth::OtpCodeService, type: :service do
  subject(:service) { described_class.new(authenticatable:) }

  let(:authenticatable) { create(:big_donor) }

  describe '#find_or_create_otp_code' do
    context 'when there is already an OTP for that authenticatable' do
      let(:otp_code) { 'r1bon' }

      before do
        allow(SecureRandom).to receive(:hex).and_return(otp_code)
        service.send(:create_otp_code)
      end

      it 'returns the link with that OTP code' do
        expect(service.find_or_create_otp_code).to eq(otp_code)
      end
    end

    context 'when there is no OTP code' do
      let(:new_otp_code) { 'rib0n' }

      before do
        allow(SecureRandom).to receive(:hex).and_return(new_otp_code)
      end

      it 'returns the link with a new OTP code' do
        expect(service.find_or_create_otp_code).to eq(new_otp_code)
      end
    end
  end

  describe '#valid_otp_code?' do
    let(:otp_code) { 'r1bon' }

    context 'when the OTP exists previously' do
      before do
        allow(SecureRandom).to receive(:hex).and_return(otp_code)
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
          expect(service.valid_otp_code?('3RR0R')).to be_falsey
        end
      end
    end

    context 'when the OTP does not exist or is expired' do
      it 'returns false' do
        expect(service.valid_otp_code?('OTHER')).to be_falsey
      end
    end
  end
end
