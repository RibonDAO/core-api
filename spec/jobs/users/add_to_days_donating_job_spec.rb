require 'rails_helper'

RSpec.describe Users::AddToDaysDonatingJob, type: :job do
  describe '#peform' do
    subject(:perform_job) { described_class.perform_now(user:) }

    describe 'when didnt donated today' do
      let(:user) do
        create(:user) do |user|
          create(:user_donation_stats, days_donating: 0, user:, last_donation_at: Time.zone.yesterday)
        end
      end

      it('adds to days donating') do
        expect { perform_job }.to change(user.user_donation_stats, :days_donating).to(1)
      end
    end

    describe 'when already donated today' do
      let(:user) do
        create(:user) do |user|
          create(:user_donation_stats, days_donating: 0, user:, last_donation_at: Time.zone.now)
        end
      end

      it('doesnt add to days donating') do
        expect { perform_job }.not_to change(user.user_donation_stats, :days_donating)
      end
    end
  end
end
