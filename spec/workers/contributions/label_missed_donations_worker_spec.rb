require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Contributions::LabelMissedDonationsWorker, type: :worker do
  include ActiveStorage::Blob::Analyzable

  describe '#perform' do
    subject(:worker) { described_class.new }

    let!(:donations_without_label) { create_list(:donation, 2) }
    let(:donations_with_label) { create_list(:donation, 2) }

    before do
      allow(Service::Contributions::TicketLabelingService).to receive(:new)
      donations_with_label.each do |donation|
        create(:donation_contribution, donation:)
      end
    end

    it 'calls the service with right params' do
      worker.perform

      expect(Service::Contributions::TicketLabelingService)
        .to have_received(:new).with(donation: donations_without_label.first)
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
      end.to change(Sidekiq::Queues['contributions'], :size).by(1)
    end
  end
end
