require 'rails_helper'

RSpec.describe Legacy::CreateLegacyIntegrationImpactJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(legacy_integration, legacy_impacts) }

    let(:legacy_integration) do
      {
        name: 'Test Integration',
        legacy_id: 1,
        created_at: 2.years.ago,
        donors_count: 100
      }
    end
    let(:legacy_impacts) do
      [{
        non_profit: { name: 'test', logo_url: 'test', impact_cost_ribons: 1000,
                      impact_cost_usd: 10, impact_description: 'test',
                      legacy_id: 1 }, total_impact: 1, total_donated_usd: 1, donations_count: 1
      }]
    end
    let(:command) { Legacy::CreateLegacyIntegrationImpact }

    before do
      allow(command).to receive(:call)
      perform_job
    end

    it 'calls CreateLegacyIntegrationImpact' do
      expect(command).to have_received(:call).with(legacy_integration:, legacy_impacts:)
    end
  end
end
