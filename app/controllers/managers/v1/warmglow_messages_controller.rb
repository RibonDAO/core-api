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

      def create
        command = WarmglowMessages::UpsertWarmglowMessage.call(warmglow_message_params)
        if command.success?
          render json: WarmglowMessageBlueprint.render(command.result), status: :created
        else
          render_errors(command.errors)
        end
      end

      def update
        command = WarmglowMessages::UpsertWarmglowMessage.call(warmglow_message_params)
        if command.success?
          render json: WarmglowMessageBlueprint.render(command.result), status: :ok
        else
          render_errors(command.errors)
        end
      end

      private

      def warmglow_message_params
        params.permit(:id, :message, :status)
      end
    end
  end
end
