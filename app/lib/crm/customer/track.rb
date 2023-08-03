module Crm
  module Customer
    class Track < Base
      def send_event(user, event)
        @client.track(
          user.email,
          event.name,
          event.data
        )
      rescue Customerio::InvalidResponse => e
        Reporter.log(error: e)
      end
    end
  end
end
