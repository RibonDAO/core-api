module Web3
  module Utils
    class Converter
      WEI_CONVERT_FACTOR = ::Eth::Unit::ETHER

      def self.parse_wei(wei_value)
        wei_value / WEI_CONVERT_FACTOR
      end

      def self.to_wei(value)
        value * WEI_CONVERT_FACTOR
      end

      def self.keccak(value, decimals = 256)
        Digest::Keccak.hexdigest(value, decimals)
      end
    end
  end
end
