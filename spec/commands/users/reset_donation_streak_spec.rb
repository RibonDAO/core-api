# frozen_string_literal: true

require 'rails_helper'

describe Users::ResetDonationStreak do
  describe '.call' do
    let(:user) { create(:user) }
    let!(:user_donation_stats) { user.user_donation_stats }
    let!(:users_donation_stats) { UserDonationStats.all }
    let(:command) { described_class.call(users_donation_stats:) }

    context 'when there is last donation at 2 days ago or more' do
      before do
        user_donation_stats.update(last_donation_at: Time.zone.today - 2.days, streak: 2)
      end

      it 'reset streak' do
        expect { command }.to change { user_donation_stats.reload.streak }.to(0)
      end
    end
  end
end
