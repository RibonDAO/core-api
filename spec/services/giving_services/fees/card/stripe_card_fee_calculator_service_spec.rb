require 'rails_helper'

RSpec.describe GivingServices::Fees::Card::StripeCardFeeCalculatorService, type: :service do
  subject(:service) { described_class.new(value:, currency:) }

  describe '#calculate_fee' do
    context 'when the currency is BRL' do
      let(:value) { 100 }
      let(:currency) { :brl }

      it 'calculates the fee correctly' do
        expect(service.calculate_fee.to_f).to eq 4.38
      end
    end

    context 'when the currency is USD' do
      let(:value) { 100 }
      let(:currency) { 'USD' }
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
        percentage_fee = (value * usd_to_brl * described_class::STRIPE_PERCENTAGE_FEE)
        final_value = (percentage_fee + 0.39) * brl_to_usd

        expect(service.calculate_fee.to_f).to eq final_value.round(2)
      end
    end
  end
end
