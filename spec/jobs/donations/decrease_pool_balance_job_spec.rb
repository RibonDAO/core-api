require 'rails_helper'

RSpec.describe Donations::DecreasePoolBalanceJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(donation:) }

    let!(:cause) { create(:cause) }
    let!(:pool) { create(:pool, cause:) }
    let!(:non_profit) { create(:non_profit, cause:) }
    let!(:donation) { create(:donation, non_profit:) }
    let(:service) { Service::Donations::PoolBalances }
    let(:service_mock) { instance_double(service) }

    before do
      create(:chain)
      create(:ribon_config, default_ticket_value: 100)
      allow(service).to receive(:new).with(pool:).and_return(service_mock)
      allow(service_mock).to receive(:decrease_balance)
      perform_job
    end

    it 'calls the service with right params' do
      expect(service).to have_received(:new).with(pool:)
      expect(service_mock).to have_received(:decrease_balance)
    end
  end
end
