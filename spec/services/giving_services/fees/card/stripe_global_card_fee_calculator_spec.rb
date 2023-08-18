require 'rails_helper'

RSpec.describe GivingServices::Fees::Card::StripeGlobalCardFeeCalculator, type: :service do
  subject(:service) { described_class.new(value:, currency:) }

  include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_usd_brl' } }

  describe '#calculate_fee' do
    context 'when the currency is USD' do
      let(:value) { 100 }
      let(:currency) { :usd }

      it 'calculates the fee correctly' do
        expect(service.calculate_fee.to_f).to eq 3.29
      end
    end

    context 'when the currency is BRL' do
      let(:value) { 100 }
      let(:currency) { 'BRL' }
      let(:mocked_instance) { mock_instance(klass: Currency::Rates) }

      let(:usd_to_brl) { 5 }
      let(:brl_to_usd) { 0.2 }

      before do
        allow(mocked_instance).to receive(:add_rate).and_return(
          Money.add_rate(:usd, :brl, usd_to_brl),
          Money.add_rate(:brl, :usd, brl_to_usd)
        )
      end

      it 'calculates the fee correctly' do
        percentage_fee = (value * brl_to_usd * described_class::STRIPE_PERCENTAGE_FEE)
        final_value = (percentage_fee + 0.3) * usd_to_brl

        expect(service.calculate_fee.to_f).to eq final_value.round(2)
      end
    end
  end
end
