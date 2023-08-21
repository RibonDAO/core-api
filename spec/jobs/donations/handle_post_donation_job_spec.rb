require 'rails_helper'

RSpec.describe Donations::HandlePostDonationJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(donation:) }

    let(:donation) { create(:donation) }

    before do
      allow(Donations::DecreasePoolBalanceJob).to receive(:perform_later)
      allow(Events::Donations::SendDonationEventJob).to receive(:perform_later)
      perform_job
    end

    it 'calls the decrease pool balance job' do
      expect(Donations::DecreasePoolBalanceJob).to have_received(:perform_later).with(donation:)
    end

    it 'calls the send donation event job' do
      expect(Events::Donations::SendDonationEventJob).to have_received(:perform_later).with(donation:)
    end
  end
end
