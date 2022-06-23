module GivingServices
  module Payment
    class GatewayFactory
      attr_reader :gateway

      NAMESPACE = 'Payment::Gateways::'.freeze

      def initialize(gateway)
        @gateway = gateway.to_s.capitalize
      end

      def call
        "#{NAMESPACE}#{gateway}".split('::').inject(Object) { |o, c| o.const_get c }
      end
    end
  end
end
