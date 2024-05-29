# frozen_string_literal: true

require 'rails_helper'

describe Users::SetLastDonatedCause do
  describe '.call' do
    subject(:command) { described_class.call(user:, cause:) }

    let(:user) { create(:user) }
    let(:cause) { create(:cause) }

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

        expect(user.user_donation_stats.last_donated_cause).to eq cause.id
      end
    end

    context 'when the user has a user_donation_stats' do
      it 'sets the user last donation to the date_to_set' do
        command

        expect(user.user_donation_stats.last_donated_cause).to eq cause.id
      end
    end
  end
end
