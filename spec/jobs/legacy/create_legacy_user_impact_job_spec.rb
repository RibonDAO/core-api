require 'rails_helper'

RSpec.describe Legacy::CreateLegacyUserImpactJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(user:, impacts:) }

    let(:user) do
      {
        email: 'test@mail',
        legacy_id: 1,
        created_at: 2.years.ago
      }
    end
    let(:impacts) do
      [{
        non_profit: { name: 'test', logo_url: 'test', cost_of_one_impact: 1, impact_description: 'test',
                      legacy_id: 1 }, total_impact: 1, total_donated_usd: 1, donations_count: 1
      }]
    end
    let(:command) { described_class }

    before do
      allow(command).to receive(:perform_now)
      perform_job
    end

    it 'calls CreateLegacyUserImpact' do
      expect(described_class).to have_received(:perform_now).with(user:, impacts:)
    end
  end
end
