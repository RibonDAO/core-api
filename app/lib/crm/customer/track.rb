module Crm
  module Customer
    class Track < Base
      def send_event(user, event)
        begin
          response = @client.track(
            user.email, 
            event.name,
            event.data
          )
        rescue Customerio::InvalidResponse => e
          return e.code, e.message
        end
      end      
    end
  end
end