require 'rails_helper'

RSpec.describe Donations::HandlePostDonationJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(donation:) }

    let(:donation) { create(:donation) }

    before do
      allow(Mailers::SendDonationsEmailJob).to receive(:perform_later)
      allow(Mailers::SendOneDonationEmailJob).to receive(:perform_later)
      allow(Donations::DecreasePoolBalanceJob).to receive(:perform_later)
      perform_job
    end

    it 'calls the send donations email job' do
      expect(Mailers::SendDonationsEmailJob).to have_received(:perform_later).with(donation:)
    end

    it 'calls the send one donation email job' do
      expect(Mailers::SendOneDonationEmailJob).to have_received(:perform_later).with(donation:)
    end

    it 'calls the decrease pool balance job' do
      expect(Donations::DecreasePoolBalanceJob).to have_received(:perform_later).with(donation:)
    end
  end
end
