module Jwt
  module Auth
    module Expiry
      module_function

      def expiry
        1.minute
      end
    end
  end
end
