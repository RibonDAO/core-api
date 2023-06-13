require 'rails_helper'

RSpec.describe Web3::Contracts::RibonContract do
  let(:chain) { build(:chain) }
  let(:client) { instance_double(::Eth::Client) }
  let(:ecr_token_contract) { instance_double(Web3::Contracts::Ecr20TokenContract) }
  let(:contract) { OpenStruct.new({}) }
  let(:amount) { 0.5 }
  let(:feeable) { true }
  let(:donation_batch) { build(:batch).cid }
  let(:donation_pool) { build(:pool) }

  describe '#add_pool_balance' do
    subject(:method_call) do
      described_class.new(chain:).add_pool_balance(donation_pool:, amount:, feeable:)
    end

    before do
      allow(Web3::Providers::Client).to receive(:create).and_return(client)

      allow(::Eth::Contract).to receive(:from_abi).and_return(contract)
      allow(client).to receive_messages(transact: {}, max_fee_per_gas: 0,
                                        max_priority_fee_per_gas: 0, gas_limit: 0)
      allow(Web3::Contracts::Ecr20TokenContract).to receive(:new).and_return(ecr_token_contract)
      allow(ecr_token_contract).to receive(:approve)
    end

    it 'calls the transact with correct args' do
      method_call
      wei_amount = Web3::Utils::Converter.to_decimals(amount, 6)
      sender_key = Web3::Providers::Keys::RIBON_KEY

      expect(client)
        .to have_received(:transact).with(
          contract, 'addPoolBalance', donation_pool.address, wei_amount, feeable, gas_limit: 0, sender_key:
        )
    end

    it 'calls the ecr token contract with correct args' do
      method_call
      wei_amount = Web3::Utils::Converter.to_decimals(amount, 6)

      expect(ecr_token_contract)
        .to have_received(:approve).with(
          spender: chain.ribon_contract_address, amount: wei_amount
        )
    end
  end

  describe '#add_integration_balance' do
    subject(:method_call) { described_class.new(chain:).add_integration_balance(integration_address:, amount:) }

    let(:integration_address) { build(:integration_wallet).public_key }

    before do
      allow(Web3::Providers::Client).to receive(:create).and_return(client)
      allow(::Eth::Contract).to receive(:from_abi).and_return(contract)
      allow(client).to receive_messages(transact: {}, max_fee_per_gas: 0,
                                        max_priority_fee_per_gas: 0, gas_limit: 0)
    end

    it 'calls the transact with correct args' do
      method_call
      wei_amount = Web3::Utils::Converter.to_wei(amount)
      sender_key = Web3::Providers::Keys::RIBON_KEY

      expect(client)
        .to have_received(:transact).with(
          contract, 'addIntegrationControllerBalance', integration_address, wei_amount, gas_limit: 0, sender_key:
        )
    end
  end

  describe '#donate_through_integration' do
    subject(:method_call) do
      described_class.new(chain:).donate_through_integration(
        donation_pool:, amount:, donation_batch:, non_profit_wallet_address:, integration_wallet_address:
      )
    end

    let(:integration_wallet_address) { build(:integration_wallet).public_key }
    let(:non_profit_wallet_address) { build(:non_profit).wallet_address }

    before do
      allow(Web3::Providers::Client).to receive(:create).and_return(client)
      allow(::Eth::Contract).to receive(:from_abi).and_return(contract)
      allow(client).to receive_messages(transact: {}, max_fee_per_gas: 0, max_priority_fee_per_gas: 0,
                                        gas_limit: 0)
    end

    it 'calls the transact with correct args' do
      method_call
      wei_amount = Web3::Utils::Converter.to_decimals(amount, 6)
      sender_key = Web3::Providers::Keys::RIBON_KEY

      expect(client)
        .to have_received(:transact).with(
          contract, 'donateThroughIntegration', donation_pool.address, non_profit_wallet_address,
          integration_wallet_address, donation_batch, wei_amount, gas_limit: 0, sender_key:
        )
    end
  end

  describe '#contribute_to_non_profit' do
    subject(:method_call) do
      described_class.new(chain:).contribute_to_non_profit(
        non_profit_pool:, non_profit_wallet_address:, amount:
      )
    end

    let(:non_profit_pool) { build(:pool) }
    let(:non_profit_wallet_address) { build(:non_profit_wallet).public_key }

    before do
      allow(Web3::Providers::Client).to receive(:create).and_return(client)
      allow(::Eth::Contract).to receive(:from_abi).and_return(contract)
      allow(client).to receive_messages(transact: {}, max_fee_per_gas: 0, max_priority_fee_per_gas: 0,
                                        gas_limit: 0)
    end

    it 'calls the transact with correct args' do
      method_call
      wei_amount = Web3::Utils::Converter.to_decimals(amount, 6)
      sender_key = Web3::Providers::Keys::RIBON_KEY

      expect(client)
        .to have_received(:transact).with(
          contract, 'contributeToNonProfit', non_profit_pool.address, non_profit_wallet_address,
          wei_amount, gas_limit: 0, sender_key:
        )
    end
  end
end
