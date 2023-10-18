module Jwt
  module Auth
    module Expiry
      module_function

      def expiry
        2.seconds
      end
    end
  end
end
