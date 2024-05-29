# frozen_string_literal: true

require 'rails_helper'

describe Users::IncrementDonationStreak do
  describe '.call' do
    let(:user) { create(:user) }
    let!(:donation_stats) { user.user_donation_stats }
    let(:command) { described_class.call(user:) }

    context 'when it is the first donation' do
      before do
        donation_stats.update(last_donation_at: nil, streak: 0)
      end

      it 'increment streak' do
        expect { command }.to change { donation_stats.reload.streak }.by(1)
      end
    end

    context 'when last donation is yesterday' do
      before do
        donation_stats.update(last_donation_at: Time.zone.yesterday)
      end

      it 'increments streak' do
        expect { command }.to change { donation_stats.reload.streak }.by(1)
      end
    end

    context 'when last donation is today anc streak is not zero' do
      before do
        donation_stats.update(last_donation_at: Time.zone.today, streak: 1)
      end

      it 'does not increments streak' do
        expect { command }.not_to change { donation_stats.reload.streak }
      end
    end

    context 'when last donation is two days ago' do
      before { donation_stats.update(last_donation_at: Time.zone.today - 2.days, streak: 1) }

      it 'does not increments streak' do
        expect { command }.to change { donation_stats.reload.streak }.by(0)
      end
    end
  end
end
