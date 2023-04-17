# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Service::Contributions::LastContributionFeeHandlerService, type: :service do
  subject(:service) do
    described_class.new(accumulated_fees_result:, contribution_balance:, contribution:)
  end

  let(:accumulated_fees_result) { 200 }
  let(:contribution_balance) { create(:contribution_balance, fees_balance_cents: 100) }
  let(:person_payment) { create(:person_payment, usd_value_cents: 1000) }
  let(:contribution) { create(:contribution, generated_fee_cents: 500, person_payment:) }
  let(:remaining_fee_handler_service) do
    instance_double(Service::Contributions::RemainingContributionFeeHandlerService)
  end
  let(:contribution_fee_creator_service) do
    instance_double(Service::Contributions::ContributionFeeCreatorService)
  end

  describe '#charge_remaining_fee' do
    before do
      allow(Service::Contributions::RemainingContributionFeeHandlerService)
        .to receive(:new).and_return(remaining_fee_handler_service)
      allow(Service::Contributions::ContributionFeeCreatorService)
        .to receive(:new).and_return(contribution_fee_creator_service)
      allow(contribution_fee_creator_service).to receive(:handle_fee_creation)
      allow(remaining_fee_handler_service).to receive(:spread_remaining_fee)
    end

    it 'creates a contribution fee with the correct parameters' do
      service.charge_remaining_fee

      expect(Service::Contributions::ContributionFeeCreatorService)
        .to have_received(:new).with(
          contribution:,
          contribution_balance:,
          fee_cents: 100,
          contribution_increased_amount_cents: 200
        )
      expect(contribution_fee_creator_service).to have_received(:handle_fee_creation)
    end

    context 'when accumulated_fees_result is greater than fees_balance_cents' do
      let(:accumulated_fees_result) { 500 }

      it 'calls RemainingContributionFeeHandlerService to spread the remaining fee' do
        service.charge_remaining_fee

        expect(remaining_fee_handler_service).to have_received(:spread_remaining_fee)
      end
    end
  end
end
