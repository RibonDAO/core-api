require 'rails_helper'

RSpec.describe Coupons::ClearExpiredCouponsJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(coupon) }

    let(:coupon) { create(:coupon, expiration_date: 1.month.ago) }
    let(:command) { Coupons::ClearExpiredCoupons }

    before do
      allow(command).to receive(:call)
      perform_job
    end

    it 'calls ClearExpiredCoupons' do
      expect(command).to have_received(:call).with(coupon:)
    end
  end
end
