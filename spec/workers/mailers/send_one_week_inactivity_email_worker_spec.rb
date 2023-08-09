require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Mailers::SendOneWeekInactivityEmailWorker, type: :worker do
  describe '#perform' do
    subject(:worker) { described_class.new }

    let(:user) { create(:user) }

    before do
      allow(RibonCoreApi).to receive(:config).and_return({ api_env: 'production' })
      allow(Mailers::SendOneWeekInactivityEmailJob).to receive(:perform_later)
    end

    it 'calls the CreateDonationsBatch command' do
      worker.perform
      expect(Mailers::SendOneWeekInactivityEmailJob).to have_received(:perform_later)
    end
  end

  describe '.perform_async' do
    it 'expects to enqueue a job' do
      expect do
        described_class.perform_async
      end.to change(described_class.jobs, :size).from(0).to(1)
    end

    it 'expects to add one job in the mailer queue' do
      expect do
        described_class.perform_async
      end.to change(Sidekiq::Queues['mailers'], :size).by(1)
    end
  end
end
