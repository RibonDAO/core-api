require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Contributions::RelabelWorker, type: :worker do
  include ActiveStorage::Blob::Analyzable

  describe '#perform' do
    subject(:worker) { described_class.new }

    before do
      allow(Labeling::RelabelService).to receive(:new)
      mock_now('2023-01-01')
    end

    it 'calls the service with right params' do
      worker.perform

      expect(Labeling::RelabelService).to have_received(:new).with(from: 3.years.ago)
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
      end.to change(Sidekiq::Queues['relabel'], :size).by(1)
    end
  end
end
