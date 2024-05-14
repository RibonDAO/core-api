module Events
  module Users
    class SendUserDeletionEmailJob < ApplicationJob
      queue_as :default

      def perform(user:, jwt:)
        send_email(user, jwt) if user.present? && jwt.present?
      end

      private

      def send_email(user, jwt)
        EventServices::SendEvent.new(user:, event: build_event(user, jwt)).call
      end

      def build_event(user, jwt)
        OpenStruct.new({
                         name: 'delete_account',
                         data: {
                           email: user.email,
                           url: url(jwt)
                         }
                       })
      end

      def url(jwt)
        "https://dapp.ribon.io/delete_account?token=#{jwt}"
      end
    end
  end
end
