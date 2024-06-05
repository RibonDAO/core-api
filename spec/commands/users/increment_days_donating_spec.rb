# frozen_string_literal: true

require 'rails_helper'

describe Users::IncrementDaysDonating do
  describe '.call' do
    let(:user) { create(:user) }
    let!(:user_donation_stats) { user.user_donation_stats }
    let(:command) { described_class.call(user:) }

    context 'when didnt donated today' do
      before do
        user_donation_stats.update(last_donation_at: Time.zone.yesterday)
      end

      it 'adds to days donating' do
        expect { command }.to change(user.user_donation_stats, :days_donating).to(1)
      end
    end

    context 'when already donated today' do
      before do
        user_donation_stats.update(last_donation_at: Time.zone.today)
      end

      it 'doesnt increment days donating' do
        expect { command }.not_to change(user.user_donation_stats, :days_donating)
      end
    end
  end
end
