module Crm
  module Customer
    class Base
      def initialize
        @client = Customerio::Client.new(
          RibonCoreApi.config[:customerio][:site_id],
          RibonCoreApi.config[:customerio][:api_key],
          region: Customerio::Regions::US
        )
      end
    end
  end
end
