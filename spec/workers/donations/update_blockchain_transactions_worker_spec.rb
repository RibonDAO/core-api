require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Donations::UpdateBlockchainTransactionsWorker, type: :worker do
  include ActiveStorage::Blob::Analyzable

  describe '#perform' do
    subject(:worker) { described_class.new }

    before do
      allow(Donations::UpdateBlockchainTransactionsJob).to receive(:perform_later)
    end

    it 'calls the UpdateBlockchainTransactionsJob' do
      worker.perform

      expect(Donations::UpdateBlockchainTransactionsJob).to have_received(:perform_later)
    end
  end

  describe '.perform_async' do
    it 'expects to enqueue a job' do
      expect do
        described_class.perform_async
      end.to change(described_class.jobs, :size).from(0).to(1)
    end

    it 'expects to add one job in the donations queue' do
      expect do
        described_class.perform_async
      end.to change(Sidekiq::Queues['donations'], :size).by(1)
    end
  end
end
