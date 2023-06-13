require 'rails_helper'

RSpec.describe Donations::UpdateBlockchainTransactionsJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now }

    before do
      allow(Donations::BlockchainTransactions::UpdateProcessingTransactions).to receive(:call)
      perform_job
    end

    it 'calls the retries commands' do
      expect(Donations::BlockchainTransactions::UpdateProcessingTransactions).to have_received(:call)
    end
  end
end
