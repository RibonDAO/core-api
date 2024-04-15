# frozen_string_literal: true

require 'rails_helper'

describe Tickets::CollectByCouponId do
  describe '.call' do
    subject(:command) { described_class.call(user:, platform: 'web', coupon_id:) }

    let!(:coupon) { create(:coupon) }
    let!(:user) { create(:user) }

    context 'when no error occurs' do
      let(:coupon_id) { coupon.id }

      it 'creates a ticket in database' do
        expect { command }.to change(Ticket, :count).by(1)
      end

      it 'creates a UserCoupon in database' do
        expect { command }.to change(UserCoupon, :count).by(1)
      end

      it 'returns the ticket created' do
        ticket = command.result[:ticket]
        expect(ticket).to eq(user.tickets.last)
      end

      it 'returns the reward text' do
        reward_text = command.result[:reward_text]
        expect(reward_text).to eq(coupon.reward_text)
      end
    end

    context 'when coupon does not exist' do
      let(:coupon_id) { 1 }

      it 'returns false' do
        result = command.result
        expect(result).to be_falsey
        expect(JSON.parse(command.errors.to_json)['message']).to eq(I18n.t('tickets.coupon_invalid'))
      end
    end

    context 'when user had already collected' do
      let(:coupon_id) { coupon.id }

      before do
        create(:user_coupon, user:, coupon:)
      end

      it 'does not create the ticket on the database' do
        expect { command }.not_to change(Ticket, :count)
      end

      it 'returns false' do
        result = command.result
        expect(result).to be_falsey
        expect(JSON.parse(command.errors.to_json)['message']).to eq(I18n.t('tickets.coupon_already_collected'))
      end
    end

    context 'when coupon is expired' do
      let(:coupon_id) { coupon.id }

      before do
        coupon.update(expiration_date: 2.days.ago)
      end

      it 'does not create the ticket on the database' do
        expect { command }.not_to change(Ticket, :count)
      end

      it 'returns false' do
        result = command.result
        expect(result).to be_falsey
        expect(JSON.parse(command.errors.to_json)['message']).to eq(I18n.t('tickets.coupon_expired'))
      end
    end
  end
end
