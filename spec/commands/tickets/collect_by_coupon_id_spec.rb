# frozen_string_literal: true

require 'rails_helper'

describe Tickets::CollectByCouponId do
  describe '.call' do
    subject(:command) { described_class.call(user:, platform: 'web', coupon_id:) }

    let!(:coupon) { create(:coupon, reward_text: 'congratulations') }
    let!(:user) { create(:user) }

    context 'when no error occurs' do
      let(:coupon_id) { coupon.id }

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
      let(:coupon_id) { coupon.id }

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

    context 'when coupon does not exist' do
      let(:coupon_id) { 1 }

      it 'returns false' do
        result = command.result
        expect(result).to be_falsey
        expect(JSON.parse(command.errors.to_json)['message']).to eq(I18n.t('tickets.coupon_invalid'))
      end
    end

    context 'when user does not exist' do
      let(:coupon_id) { coupon.id }
      let(:user) { nil }

      it 'returns false' do
        result = command.result
        expect(result).to be_falsey
        expect(JSON.parse(command.errors.to_json)['message']).to eq('Validation failed: User must exist')
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

    context 'when coupon is unavailable' do
      let(:coupon_id) { coupon.id }

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
