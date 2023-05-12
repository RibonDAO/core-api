require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Contributions::CreateContributionForMissedPaymentsWorker, type: :worker do
  include ActiveStorage::Blob::Analyzable

  describe '#perform' do
    subject(:worker) { described_class.new }

    let!(:paid_payments_without_contribution) { create_list(:person_payment, 2, status: :paid) }
    let(:paid_payments_with_contribution) { create_list(:person_payment, 2, status: :paid) }

    before do
      allow(Contributions::CreateContribution).to receive(:call)
      paid_payments_with_contribution.each do |payment|
        create(:contribution, person_payment: payment)
      end
    end

    it 'calls the service with right params' do
      worker.perform

      expect(Contributions::CreateContribution)
        .to have_received(:call).with(payment: paid_payments_without_contribution.first)
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
