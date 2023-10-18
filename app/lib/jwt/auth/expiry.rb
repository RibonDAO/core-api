module Jwt
  module Auth
    module Expiry
      module_function

      def expiry
        2.hours
      end
    end
  end
end
