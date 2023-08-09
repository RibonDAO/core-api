# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Service::Contributions::ContributionFeeCreatorService, type: :service do
  subject(:service) do
    described_class.new(
      contribution_balance:,
      fee_cents:,
      contribution_increased_amount_cents:,
      contribution:
    )
  end

  let(:contribution_balance) { create(:contribution_balance) }
  let(:fee_cents) { 100 }
  let(:contribution_increased_amount_cents) { 500 }
  let(:contribution) { create(:contribution) }

  describe '#handle_fee_creation' do
    before do
      allow(::Contributions::UpdateContributionBalance).to receive(:call)
    end

    it 'creates a contribution fee' do
      expect { service.handle_fee_creation }.to change(ContributionFee, :count).by(1)
    end

    it 'creates a contribution fee with the right params' do
      service.handle_fee_creation

      expect(ContributionFee.last)
        .to match an_object_containing(
          contribution:, fee_cents:,
          payer_contribution: contribution_balance.contribution,
          payer_contribution_increased_amount_cents: contribution_increased_amount_cents
        )
    end

    it 'updates the contribution balance' do
      service.handle_fee_creation

      expect(::Contributions::UpdateContributionBalance).to have_received(:call).with(
        contribution_balance:,
        fee_cents:,
        contribution_increased_amount_cents:
      )
    end
  end
end
