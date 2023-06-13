module Web3
  module Contracts
    class RibonContract < BaseContract
      def add_pool_balance(donation_pool:, amount:, feeable:)
        parsed_amount = Utils::Converter.to_decimals(amount, donation_pool.token.decimals)
        token = donation_pool.token.address
        Web3::Contracts::Ecr20TokenContract.new(chain:, token:).approve(spender: address, amount: parsed_amount)
        transact('addPoolBalance', donation_pool.address,
                 parsed_amount, feeable, sender_key: Providers::Keys::RIBON_KEY)
      end

      def add_integration_balance(integration_address:, amount:)
        parsed_amount = Utils::Converter.to_wei(amount)

        transact('addIntegrationControllerBalance', integration_address, parsed_amount,
                 sender_key: Providers::Keys::RIBON_KEY)
      end

      def donate_through_integration(donation_pool:,
                                     non_profit_wallet_address:,
                                     integration_wallet_address:,
                                     donation_batch:,
                                     amount:)

        parsed_amount = Utils::Converter.to_decimals(amount, donation_pool.token.decimals)

        transact('donateThroughIntegration',
                 donation_pool.address,
                 non_profit_wallet_address,
                 integration_wallet_address,
                 donation_batch, parsed_amount, sender_key: Providers::Keys::RIBON_KEY)
      end

      def contribute_to_non_profit(non_profit_pool:,
                                   non_profit_wallet_address:,
                                   amount:)

        parsed_amount = Utils::Converter.to_decimals(amount, non_profit_pool.token.decimals)

        transact('contributeToNonProfit',
                 non_profit_pool.address,
                 non_profit_wallet_address,
                 parsed_amount, sender_key: Providers::Keys::RIBON_KEY)
      end

      def create_pool(token:)
        gas_limit = gas_limit_for_create_pool
        hash = transact_and_wait('createPool', token, gas_limit:, sender_key: Providers::Keys::RIBON_KEY)
        wait_for_tx(hash)
        hash
      end

      private

      def contract_name
        'RibonContract'.freeze
      end

      def address
        (::Eth::Address.new chain[:ribon_contract_address]).address
      end

      def abi
        File.read("#{Rails.root}/app/lib/web3/utils/abis/ribon_abi.json")
      end

      def gas_limit_for_create_pool
        500_000
      end
    end
  end
end
