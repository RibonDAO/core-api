require 'rails_helper'

RSpec.describe Donations::RetryBatchTransactionsJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now }

    before do
      allow(Donations::BlockchainTransactions::UpdateProcessingTransactions).to receive(:call)
      allow(Donations::BlockchainTransactions::UpdateApiOnlyTransactions).to receive(:call)
      allow(Donations::BlockchainTransactions::UpdateFailedTransactions).to receive(:call)
      perform_job
    end

    it 'calls the retries commands' do
      expect(Donations::BlockchainTransactions::UpdateApiOnlyTransactions).to have_received(:call)
      expect(Donations::BlockchainTransactions::UpdateProcessingTransactions).to have_received(:call)
      expect(Donations::BlockchainTransactions::UpdateFailedTransactions).to have_received(:call)
    end
  end
end
