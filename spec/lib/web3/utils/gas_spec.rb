require 'rails_helper'

RSpec.describe Web3::Utils::Gas do
  describe '#estimate_gas' do
    subject(:gas_lib) { described_class.new(chain:) }

    let!(:default_max_fee_per_gas) { described_class::DEFAULT_MAX_FEE_PER_GAS }
    let!(:default_max_priority_fee_per_gas) { described_class::DEFAULT_MAX_PRIORITY_FEE_PER_GAS }
    let(:chain) { build(:chain) }
    let(:mock_response) do
      OpenStruct.new(
        { 'timestamp' => '2022-09-05T11:17:05.689Z',
          'baseFee' => 1.5701499999999995e-07,
          'lastBlock' => 32_719_610,
          'avgTime' => 2.0854271356783918,
          'avgTx' => 148.37,
          'avgGas' => 173_187.72480296827,
          'speeds' =>
         [{ 'acceptance' => 0.35, 'maxFeePerGas' => max_fee_per_gas,
            'maxPriorityFeePerGas' => max_priority_fee_per_gas, 'estimatedFee' => 0.005829318909459386 },
          { 'acceptance' => 0.6, 'maxFeePerGas' => max_fee_per_gas,
            'maxPriorityFeePerGas' => max_priority_fee_per_gas, 'estimatedFee' => 0.008015313398343337 },
          { 'acceptance' => 1, 'maxFeePerGas' => max_fee_per_gas,
            'maxPriorityFeePerGas' => max_priority_fee_per_gas, 'estimatedFee' => 0.01502401780788502 },
          { 'acceptance' => 1, 'maxFeePerGas' => max_fee_per_gas,
            'maxPriorityFeePerGas' => max_priority_fee_per_gas, 'estimatedFee' => 0.01502401780788502 }] }
      )
    end
    let(:max_fee_per_gas) { default_max_fee_per_gas }
    let(:max_priority_fee_per_gas) { default_max_priority_fee_per_gas }

    before do
      allow(Request::ApiRequest).to receive(:get).and_return(mock_response)
    end

    it 'returns the correct fields' do
      expect(gas_lib.estimate_gas.to_h.keys)
        .to match_array(%i[max_fee_per_gas max_priority_fee_per_gas default_gas_limit])
    end

    context 'when the fees from api are lower than the defined max fees' do
      it 'returns the api fees' do
        expect(gas_lib.estimate_gas.max_fee_per_gas).to eq max_fee_per_gas
        expect(gas_lib.estimate_gas.max_priority_fee_per_gas).to eq max_priority_fee_per_gas
      end
    end

    context 'when the fees from api are higher than the defined max fees' do
      let(:max_fee_per_gas) { default_max_fee_per_gas + 5 }
      let(:max_priority_fee_per_gas) { default_max_priority_fee_per_gas + 5 }

      it 'returns the defined max fees' do
        expect(gas_lib.estimate_gas.max_fee_per_gas).to eq described_class::DEFAULT_MAX_FEE_PER_GAS
        expect(gas_lib.estimate_gas.max_priority_fee_per_gas).to eq default_max_priority_fee_per_gas
      end
    end

    context 'when an error occurs' do
      before do
        allow(Request::ApiRequest).to receive(:get).and_raise(StandardError)
      end

      it 'returns the default defined values' do
        expect(gas_lib.estimate_gas.max_fee_per_gas).to eq described_class::DEFAULT_MAX_FEE_PER_GAS
        expect(gas_lib.estimate_gas.max_priority_fee_per_gas).to eq default_max_priority_fee_per_gas
        expect(gas_lib.estimate_gas.default_gas_limit).to eq described_class::DEFAULT_GAS_LIMIT
      end
    end
  end
end
