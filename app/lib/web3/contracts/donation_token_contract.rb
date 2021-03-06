module Web3
  module Contracts
    class DonationTokenContract < BaseContract
      private

      def contract_name
        'DonationTokenContract'.freeze
      end

      def address
        (::Eth::Address.new network[:donation_token_contract_address]).address
      end

      def abi
        File.read("#{Rails.root}/app/lib/web3/utils/abis/donation_token_abi.json")
      end
    end
  end
end
