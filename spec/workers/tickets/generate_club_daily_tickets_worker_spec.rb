require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Tickets::GenerateClubDailyTicketsWorker, type: :worker do
  include ActiveStorage::Blob::Analyzable

  describe '#perform' do
    subject(:worker) { described_class.new }

    let(:integration) { create(:integration) }
    let(:customer) { create(:customer) }
    let(:user) { customer.user }
    let(:platform) { 'app' }
    let(:quantity) { 2 }
    let(:plan) { create(:plan, daily_tickets: 2) }
    let(:offer) { create(:offer, plans: [plan], category: :club) }

    before do
      allow(Tickets::GenerateClubDailyTicketsJob).to receive(:perform_later).with(user:, platform:,
                                                                                  quantity:, integration:)

      create(:subscription, integration:, status: :active, platform:,
                            offer:, payer: customer)
    end

    it 'calls the GenerateClubDailyTicketsJob' do
      worker.perform

      expect(Tickets::GenerateClubDailyTicketsJob).to have_received(:perform_later).with(user:,
                                                                                         platform:,
                                                                                         quantity:,
                                                                                         integration:)
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
