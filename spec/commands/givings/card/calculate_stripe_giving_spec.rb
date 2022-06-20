# frozen_string_literal: true

require 'rails_helper'

describe Givings::Card::CalculateStripeGiving do
  subject(:command) { described_class.call(value:, currency:) }

  let(:value) { 40 }
  let(:currency) { :brl }
  let(:calculate_card_fee) { Money.from_amount(0.5, currency) }
  let(:calculate_crypto_fee) { Money.from_amount(0.05, currency) }
  let(:add_rate) { Money.add_rate(currency, :usd, 0.2) }

  describe '.call' do
    before do
      mock_instance(klass: GivingServices::Fees::Card::StripeCardFeeCalculatorService,
                    methods: { calculate_fee: calculate_card_fee })
      mock_instance(klass: GivingServices::Fees::Crypto::PolygonFeeCalculatorService,
                    methods: { calculate_fee: calculate_crypto_fee })
      mock_instance(klass: Currency::Rates, methods: { add_rate: })
    end

    it 'returns a hash with correct params' do
      expect(command.result.keys)
        .to match_array %i[card_fee crypto_fee
                           crypto_giving giving_total net_giving service_fees]
    end

    it 'returns the correct net giving' do
      expect(command.result[:net_giving]).to eq 'R$39.45'
    end

    it 'returns the correct card fee' do
      expect(command.result[:card_fee]).to eq 'R$0.50'
    end

    it 'returns the correct crypto fee' do
      expect(command.result[:crypto_fee]).to eq 'R$0.05'
    end

    it 'returns the correct service_fees' do
      expect(command.result[:service_fees]).to eq 'R$0.55'
    end

    it 'returns the correct crypto giving' do
      expect(command.result[:crypto_giving]).to eq '$7.78'
    end

    it 'returns the correct giving_total' do
      expect(command.result[:giving_total]).to eq 'R$40.00'
    end
  end
end
