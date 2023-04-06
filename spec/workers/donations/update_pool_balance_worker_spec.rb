require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Donations::UpdatePoolBalanceWorker, type: :worker do
  include ActiveStorage::Blob::Analyzable

  describe '#perform' do
    subject(:worker) { described_class.new }

    let(:pool) { create(:pool) }
    let(:job) { Donations::UpdatePoolBalanceJob }

    before do
      allow(Rails.env).to receive(:production?).and_return(true)
      allow(job).to receive(:perform_later).with(pool:)
    end

    it 'calls the service with right params' do
      worker.perform
      expect(job).to have_received(:perform_later).with(pool:)
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
