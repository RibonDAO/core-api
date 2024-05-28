require 'rails_helper'

RSpec.describe Users::UpdateDonationStatsJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(donation:) }

    let!(:donation) { create(:donation) }
    let(:user) { donation.user }

    before do
      allow(Users::SetUserLastDonationAt).to receive(:call)
        .and_return(command_double(klass: Users::SetUserLastDonationAt))
      allow(Users::SetLastDonatedCause).to receive(:call)
        .and_return(command_double(klass: Users::SetLastDonatedCause))
      allow(Users::IncrementDonationStreak).to receive(:call)
        .and_return(command_double(klass: Users::IncrementDonationStreak))
      perform_job
    end

    it 'calls the Users::SetUserLastDonationAt' do
      expect(Users::SetUserLastDonationAt)
        .to have_received(:call).with(user:, date_to_set: donation.created_at)
    end

    it 'calls the Users::SetLastDonatedCause' do
      expect(Users::SetLastDonatedCause)
        .to have_received(:call).with(user:, cause: donation.non_profit.cause)
    end

    it 'calls the Users::IncrementDonationStreak' do
      expect(Users::IncrementDonationStreak)
        .to have_received(:call).with(user:)
    end
  end
end
