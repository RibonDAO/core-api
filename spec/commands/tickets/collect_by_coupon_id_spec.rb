# frozen_string_literal: true

require 'rails_helper'

describe Tickets::CollectByCouponId do
  describe '.call' do
    subject(:command) { described_class.call(user:, platform: 'web', coupon:) }

    let!(:coupon) { create(:coupon) }
    let!(:user) { create(:user) }

    context 'when no error occurs' do
      it 'creates a ticket in database' do
        expect { command }.to change(Ticket, :count).by(1)
      end

      it 'creates a UserCoupon in database' do
        expect { command }.to change(UserCoupon, :count).by(1)
      end

      it 'returns the ticket created and the reward text' do
        result = command.result
        expect(result[:tickets]).to eq(user.tickets)
        expect(result[:coupon]).to eq(coupon)
      end
    end

    context 'when number of tickets is greater than 1' do
      before do
        coupon.update(number_of_tickets: 2)
      end

      it 'creates a ticket in database' do
        expect { command }.to change(Ticket, :count).by(2)
      end

      it 'creates a UserCoupon in database' do
        expect { command }.to change(UserCoupon, :count).by(1)
      end

      it 'returns the ticket created and the reward text' do
        result = command.result
        expect(result[:tickets]).to eq(user.tickets)
        expect(result[:coupon]).to eq(coupon)
      end
    end

    context 'when user had already collected' do
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

    context 'when coupon is unavailable' do
      before do
        create(:user_coupon, coupon:)
        coupon.update(available_quantity: 1)
      end

      it 'does not create the ticket on the database' do
        expect { command }.not_to change(Ticket, :count)
      end

      it 'returns false' do
        result = command.result
        expect(result).to be_falsey
        expect(JSON.parse(command.errors.to_json)['message']).to eq(I18n.t('tickets.coupon_unavailable'))
      end
    end
  end
end
