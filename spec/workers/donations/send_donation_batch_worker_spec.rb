require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Donations::SendDonationBatchWorker, type: :worker do
  include ActiveStorage::Blob::Analyzable

  describe '#perform' do
    subject(:worker) { described_class.new }

    let(:integration) { create(:integration) }
    let(:non_profit) { create(:non_profit) }
    let(:result) do
      OpenStruct.new({
                       result: create(:batch)
                     })
    end

    before do
      allow(Kernel).to receive(:sleep)
      allow(Donations::CreateDonationsBatch).to receive(:call).and_return(result)
    end

    it 'calls the CreateDonationsBatch command' do
      Donations::CreateDonationsBatch.call(non_profit:, integration:)

      expect(Donations::CreateDonationsBatch).to have_received(:call)

      worker.perform
    end
  end

  describe '.perform_async' do
    it 'expects to enqueue a job' do
      expect do
        described_class.perform_async
      end.to change(described_class.jobs, :size).from(0).to(1)
    end

    it 'expects to add one job in the batches queue' do
      expect do
        described_class.perform_async
      end.to change(Sidekiq::Queues['batches'], :size).by(1)
    end
  end
end
