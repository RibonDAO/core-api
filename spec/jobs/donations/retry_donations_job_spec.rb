require 'rails_helper'

RSpec.describe Donations::RetryDonationsJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now }

    before do
      allow(Donations::UpdateProcessingDonations).to receive(:call)
      allow(Donations::UpdateFailedDonations).to receive(:call)
      perform_job
    end

    it 'calls the retries commands' do
      expect(Donations::UpdateProcessingDonations).to have_received(:call)
      expect(Donations::UpdateFailedDonations).to have_received(:call)
    end
  end
end
