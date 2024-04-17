# frozen_string_literal: true

require 'rails_helper'

describe Coupons::ClearExpiredCoupons do
  describe '.call' do
    subject(:command) { described_class.call(coupon:) }

    let(:coupon) { create(:coupon, expiration_date: Time.zone.now.days_ago(1)) }

    context 'when no error occurs' do
      before do
        create_list(:user_coupon, 3, coupon:)
      end

      it 'moves expired user coupons to UserExpiredCoupon' do
        expect do
          described_class.call(coupon:)
        end.to change(UserExpiredCoupon, :count).by(3)
      end

      it 'deletes expired user coupons' do
        expect do
          described_class.call(coupon:)
        end.to change(UserCoupon, :count).by(-3)
      end
    end
  end
end
