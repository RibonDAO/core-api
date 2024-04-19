# frozen_string_literal: true

require 'rails_helper'

describe Tickets::CanCollectByCouponId do
  describe '.call' do
    subject(:command) { described_class.call(coupon:, user:) }

    let!(:coupon) { create(:coupon) }
    let!(:user) { create(:user) }

    context 'when no error occurs' do
      it 'returns true' do
        result = command.result
        expect(result).to be_truthy
      end
    end

    context 'when user had already collected' do
      before do
        create(:user_coupon, user:, coupon:)
      end

      it 'returns false' do
        result = command.result
        expect(result).to be_falsey
        expect(JSON.parse(command.errors.to_json)['message']).to eq(I18n.t('tickets.coupon_already_collected'))
      end
    end

    context 'when coupon is expired' do
      before do
        coupon.update(expiration_date: 2.days.ago)
      end

      it 'returns false' do
        result = command.result
        expect(result).to be_falsey
        expect(JSON.parse(command.errors.to_json)['message']).to eq(I18n.t('tickets.coupon_expired'))
      end
    end

    context 'when coupon is unavailable' do
      before do
        create(:user_coupon, coupon:)
        coupon.update(available_quantity: 1)
      end

      it 'returns false' do
        result = command.result
        expect(result).to be_falsey
        expect(JSON.parse(command.errors.to_json)['message']).to eq(I18n.t('tickets.coupon_unavailable'))
      end
    end
  end
end
