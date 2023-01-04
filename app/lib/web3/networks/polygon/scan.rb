module Web3
  module Networks
    module Polygon
      class Scan
        def initialize(pool_address:)
          @pool_address = pool_address
        end

        def balance
          result = Request::ApiRequest.get("#{base_url}?" \
                                           'module=account&' \
                                           'action=tokenbalance&' \
                                           "contractaddress=#{contract_address}&" \
                                           "address=#{@pool_address}&" \
                                           'tag=latest&' \
                                           "apikey=#{api_key}")
          return 0 unless result['result']

          result['result'].to_i
        end

        private

        def api_key
          RibonCoreApi.config[:polygon_scan][:api_key]
        end

        def base_url
          'https://api.polygonscan.com/api'
        end

        def contract_address
          Token.default.address
        end
      end
    end
  end
end
