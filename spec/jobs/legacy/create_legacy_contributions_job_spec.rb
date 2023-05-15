require 'rails_helper'

RSpec.describe Legacy::CreateLegacyContributionsJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(user, legacy_contribution) }

    let(:user) do
      {
        email: 'test@mail',
        legacy_id: 1,
        created_at: 2.years.ago
      }
    end
    let(:legacy_contribution) do
      {
        created_at: '2023-05-15T09:26:52-03:00',
        value_cents: 500,
        legacy_payment_id: 1,
        legacy_payment_method: :credit_card,
        legacy_payment_platform: :iugu,
        from_subscription: true
      }
    end
    let(:command) { Legacy::CreateLegacyContribution }

    before do
      allow(command).to receive(:call)
      perform_job
    end

    it 'calls CreateLegacyUserImpact' do
      expect(command).to have_received(:call).with(legacy_user: user, legacy_contribution:)
    end
  end
end
