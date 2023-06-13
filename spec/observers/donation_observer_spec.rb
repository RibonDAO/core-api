require 'rails_helper'

RSpec.describe DonationObserver, type: :observer do
  describe 'if a donation is created' do
    let(:donation) { build(:donation) }

    before do
      allow(Donations::HandlePostDonationJob).to receive(:perform_later).with(donation:)
    end

    it 'calls the handle post donation job' do
      donation.save
      expect(Donations::HandlePostDonationJob).to have_received(:perform_later).with(donation:)
    end
  end
end
