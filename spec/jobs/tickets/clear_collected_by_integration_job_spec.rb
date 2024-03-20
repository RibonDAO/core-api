require 'rails_helper'

RSpec.describe Tickets::ClearCollectedByIntegrationJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(integration, user) }

    let(:integration) { create(:integration) }
    let(:user) { create(:user) }
    let(:command) { Tickets::ClearCollectedByIntegration }

    before do
      allow(command).to receive(:call)
      perform_job
    end

    it 'calls ClearCollectedByIntegration' do
      expect(command).to have_received(:call).with(integration:, user:)
    end
  end
end
