require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Users::ResetEveryoneDonationStreakWorker, type: :worker do
  describe '#perform' do
    subject(:worker) { described_class.new }

    let(:users_donation_stats) { UserDonationStats.all }

    before do
      allow(Users::ResetDonationStreakJob).to receive(:perform_later)
      create_list(:user_donation_stats, 10, streak: 5)
    end

    it 'calls the ResetDonationsStreakJob' do
      worker.perform

      expect(Users::ResetDonationStreakJob).to have_received(:perform_later).with(users_donation_stats:)
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
      end.to change(Sidekiq::Queues['users'], :size).by(1)
    end
  end
end
