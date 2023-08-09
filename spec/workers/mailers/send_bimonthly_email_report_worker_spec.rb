require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Mailers::SendBimonthlyEmailReportWorker, type: :worker do
  describe '#perform' do
    let(:user1) { create(:user) }
    let(:user3) { create(:user) }
    let(:user_stats1) { create(:user_donation_stats, last_donation_at: 1.month.ago) }
    let(:user_stats3) { create(:user_donation_stats, last_donation_at: 4.months.ago) }

    before do
      allow(Mailers::HandleBimonthlyEmailReportJob).to receive(:perform_later)
    end

    it 'sends free bimonthly email report to users with last donation between 3 and 2 months ago' do
      create(:user)
      create(:user_donation_stats, last_donation_at: 2.months.ago)

      described_class.new.perform

      expect(Mailers::HandleBimonthlyEmailReportJob).to have_received(:perform_later)
        .with(user: an_instance_of(User))
    end

    it 'does not send a bimonthly email report to users with last donation smaller than 3 and 2 months ago' do
      described_class.new.perform

      expect(Mailers::HandleBimonthlyEmailReportJob).not_to have_received(:perform_later).with(user: user_stats1)
    end

    it 'does not send a bimonthly email report to users with last donation higher than 3 and 2 months ago' do
      described_class.new.perform

      expect(Mailers::HandleBimonthlyEmailReportJob).not_to have_received(:perform_later).with(user: user_stats3)
    end

    it 'logs any errors raised during execution' do
      create(:user)
      create(:user_donation_stats, last_donation_at: 2.months.ago)

      allow(Mailers::HandleBimonthlyEmailReportJob).to receive(:perform_later).and_raise(StandardError)
      allow(Reporter).to receive(:log)

      described_class.new.perform

      expect(Reporter).to have_received(:log)
    end
  end

  describe '.perform_async' do
    it 'expects to enqueue a job' do
      expect do
        described_class.perform_async
      end.to change(described_class.jobs, :size).from(0).to(1)
    end

    it 'expects to add one job in the mailers queue' do
      expect do
        described_class.perform_async
      end.to change(Sidekiq::Queues['mailers'], :size).by(1)
    end
  end
end
