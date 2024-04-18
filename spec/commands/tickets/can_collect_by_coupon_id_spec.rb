# frozen_string_literal: true

require 'rails_helper'

describe Tickets::CanCollectByCouponId do
  describe '.call' do
    subject(:command) { described_class.call(coupon_id:, user_id:) }

    let!(:coupon) { create(:coupon) }
    let(:coupon_id) { coupon.id }
    let!(:user) { create(:user) }
    let(:user_id) { user.id }

    context 'when no error occurs' do
      it 'returns true' do
        result = command.result
        expect(result).to be_truthy
      end
    end

    context 'when user had already collected' do
      before do
        create(:user_coupon, user_id:, coupon_id:)
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
  end
end
