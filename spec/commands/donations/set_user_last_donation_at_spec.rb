# frozen_string_literal: true

require 'rails_helper'

describe Donations::SetUserLastDonationAt do
  describe '.call' do
    subject(:command) { described_class.call(user:, date_to_set:) }

    let(:user) { create(:user) }
    let(:date_to_set) { Date.parse('2021-01-12 10:00:00') }

    context 'when the user does not have a user_donation_stats' do
      before do
        User.skip_callback(:create, :after, :set_user_donation_stats)
        allow(user).to receive(:create_user_donation_stats!).and_call_original
      end

      after do
        User.set_callback(:create, :after, :set_user_donation_stats)
      end

      it 'creates a donation stats for the user' do
        command

        expect(user).to have_received(:create_user_donation_stats!)
      end

      it 'sets the user last donation to the date_to_set' do
        command

        expect(user.last_donation_at).to eq date_to_set
      end
    end

    context 'when the user has a user_donation_stats' do
      it 'sets the user last donation to the date_to_set' do
        command

        expect(user.last_donation_at).to eq date_to_set
      end
    end
  end
end
