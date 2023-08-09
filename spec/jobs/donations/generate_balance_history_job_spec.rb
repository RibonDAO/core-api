require 'rails_helper'

RSpec.describe Donations::GenerateBalanceHistoryJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(pool:) }

    let(:pool) { build(:pool) }
    let(:service) { Service::Donations::PoolBalances }
    let(:service_mock) { instance_double(service) }

    before do
      allow(service).to receive(:new).with(pool:).and_return(service_mock)
      allow(service_mock).to receive(:add_balance_history)
      perform_job
    end

    it 'calls the service with right params' do
      expect(service).to have_received(:new).with(pool:)
      expect(service_mock).to have_received(:add_balance_history)
    end
  end
end
