module Web3
  module Providers
    class Keys
      config = RibonCoreApi.config[:web3][:wallets]

      RIBON_KEY = ::Eth::Key.new(priv: config[:ribon_wallet_private_key])

      def self.generate_keypair
        key = ::Eth::Key.new

        [
          key.address.address,
          key.private_hex
        ]
      end
    end
  end
end
