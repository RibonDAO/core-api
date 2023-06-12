module Jwt
  module Auth
    module Expiry
      module_function

      def expiry
        10.seconds
      end
    end
  end
end
