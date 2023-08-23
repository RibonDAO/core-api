# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Service::Contributions::ContributionFeeDeleteService, type: :service do
  subject(:service) do
    described_class.new(
      contribution_fee:
    )
  end

  let!(:contribution) { create(:contribution, :with_contribution_balance) }
  let!(:payer_contribution) { create(:contribution, :with_contribution_balance) }
  let!(:contribution_fee) { create(:contribution_fee, contribution:, payer_contribution:) }

  describe '#handle_fee_delete' do
    before do
      allow(::Contributions::IncreaseContributionBalanceFee).to receive(:call)
    end

    it 'delete a contribution fee' do
      expect { service.handle_fee_delete }.to change(ContributionFee, :count).by(-1)
    end

    it 'updates the contribution balance' do
      service.handle_fee_delete

      expect(::Contributions::IncreaseContributionBalanceFee).to have_received(:call).with(
        contribution_balance: payer_contribution.contribution_balance,
        fee_cents: contribution_fee.fee_cents
      )
    end
  end
end
