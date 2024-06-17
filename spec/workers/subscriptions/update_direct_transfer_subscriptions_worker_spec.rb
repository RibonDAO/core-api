require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Subscriptions::UpdateDirectTransferSubscriptionsWorker, type: :worker do
  include ActiveStorage::Blob::Analyzable

  describe '#perform' do
    subject(:worker) { described_class.new }

    before do
      allow(Subscriptions::UpdateDirectTransferSubscriptionsJob).to receive(:perform_later)
    end

    it 'calls the UpdateDirectTransferSubscriptionsJob' do
      worker.perform

      expect(Subscriptions::UpdateDirectTransferSubscriptionsJob).to have_received(:perform_later)
    end
  end

  describe '.perform_async' do
    it 'expects to enqueue a job' do
      expect do
        described_class.perform_async
      end.to change(described_class.jobs, :size).from(0).to(1)
    end

    it 'expects to add one job in the Subscriptions queue' do
      expect do
        described_class.perform_async
      end.to change(Sidekiq::Queues['subscriptions'], :size).by(1)
    end
  end
end
