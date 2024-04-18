require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Coupons::ClearExpiredCouponsWorker, type: :worker do
  include ActiveStorage::Blob::Analyzable

  describe '#perform' do
    subject(:worker) { described_class.new }

    before do
      allow(Coupons::ClearExpiredCouponsJob).to receive(:perform_later)
      create(:coupon, expiration_date: 1.month.ago)
    end

    it 'calls the RetryBatchTransactionsJob' do
      worker.perform

      expect(Coupons::ClearExpiredCouponsJob).to have_received(:perform_later)
    end
  end

  describe '.perform_async' do
    it 'expects to enqueue a job' do
      expect do
        described_class.perform_async
      end.to change(described_class.jobs, :size).from(0).to(1)
    end

    it 'expects to add one job in the coupons queue' do
      expect do
        described_class.perform_async
      end.to change(Sidekiq::Queues['coupons'], :size).by(1)
    end
  end
end
