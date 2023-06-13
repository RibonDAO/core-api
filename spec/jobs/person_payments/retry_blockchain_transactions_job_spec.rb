require 'rails_helper'

RSpec.describe PersonPayments::RetryBlockchainTransactionsJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now }

    before do
      allow(PersonPayments::BlockchainTransactions::UpdateProcessingTransactions).to receive(:call)
      allow(PersonPayments::BlockchainTransactions::UpdateApiOnlyTransactions).to receive(:call)
      allow(PersonPayments::BlockchainTransactions::UpdateFailedTransactions).to receive(:call)
      perform_job
    end

    it 'calls the retries commands' do
      expect(PersonPayments::BlockchainTransactions::UpdateApiOnlyTransactions).to have_received(:call)
      expect(PersonPayments::BlockchainTransactions::UpdateProcessingTransactions).to have_received(:call)
      expect(PersonPayments::BlockchainTransactions::UpdateFailedTransactions).to have_received(:call)
    end
  end
end
