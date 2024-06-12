module Managers
  module V1
    class WarmglowMessagesController < ManagersController
      def index
        @warmglow_messages = WarmglowMessage.all

        render json: WarmglowMessageBlueprint.render(@warmglow_messages)
      end

      def show
        @warmglow_message = WarmglowMessage.find warmglow_message_params[:id]

        render json: WarmglowMessageBlueprint.render(@warmglow_message)
      end

      private

      def warmglow_message_params
        params.permit(:id, :message, :status)
      end
    end
  end
end
