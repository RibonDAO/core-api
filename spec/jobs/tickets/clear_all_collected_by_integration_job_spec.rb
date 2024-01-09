require 'rails_helper'

RSpec.describe Tickets::ClearAllCollectedByIntegrationJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(integration) }

    let(:integration) { create(:integration) }
    let(:command) { Tickets::ClearAllCollectedByIntegration }

    before do
      allow(command).to receive(:call)
      perform_job
    end

    it 'calls ClearAllCollectedByIntegration' do
      expect(command).to have_received(:call).with(integration:)
    end
  end
end
