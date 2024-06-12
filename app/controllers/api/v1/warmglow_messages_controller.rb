module Api
  module V1
    class WarmglowMessagesController < ApplicationController
      def random_message
        
        @warmglow_message = WarmglowMessage.where(status: :active).order("RANDOM()").first
       if @warmglow_message.present?
          render json: { message: @warmglow_message.message }
        else
          render json: { message: I18n.t('warmglow_messages.default_message') }
        end
      end

    end
  end
end
