require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Tickets::ClearAllCollectedByIntegrationWorker, type: :worker do
  include ActiveStorage::Blob::Analyzable

  describe '#perform' do
    subject(:worker) { described_class.new }

    before do
      allow(Tickets::ClearAllCollectedByIntegrationJob).to receive(:perform_later)
      create(:integration)
    end

    it 'calls the RetryBatchTransactionsJob' do
      worker.perform

      expect(Tickets::ClearAllCollectedByIntegrationJob).to have_received(:perform_later)
    end
  end

  describe '.perform_async' do
    it 'expects to enqueue a job' do
      expect do
        described_class.perform_async
      end.to change(described_class.jobs, :size).from(0).to(1)
    end

    it 'expects to add one job in the tickets queue' do
      expect do
        described_class.perform_async
      end.to change(Sidekiq::Queues['tickets'], :size).by(1)
    end
  end
end
