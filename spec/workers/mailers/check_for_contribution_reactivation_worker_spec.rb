require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Mailers::CheckForContributionReactivationWorker, type: :worker do
  describe '#perform' do
    subject(:worker) { described_class.new }

    let(:user) { create(:user) }

    before do
      allow(Mailers::SendContributionReactivationEmailJob).to receive(:perform_later)
    end

    context 'when there are users that donated lastly in 1 month' do
      before do
        create(:person_payment, payer: create(:customer, user:), paid_date: 1.month.ago)
      end

      it 'calls the SendContributionReactivationEmailJob command' do
        worker.perform

        expect(Mailers::SendContributionReactivationEmailJob).to have_received(:perform_later).with(user:)
      end
    end

    context 'when there are no users that donated lastly in 1 month' do
      it 'does not call the SendContributionReactivationEmailJob command' do
        worker.perform

        expect(Mailers::SendContributionReactivationEmailJob).not_to have_received(:perform_later)
      end
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
