require 'rails_helper'

RSpec.describe PersonPayments::CreateContributionJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(payment) }

    let(:payment) { create(:person_payment) }

    before do
      allow(Contributions::CreateContribution).to receive(:call)
      perform_job
    end

    it 'calls the create contribution command with correct params' do
      expect(Contributions::CreateContribution).to have_received(:call).with(payment:)
    end
  end
end
