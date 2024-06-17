module WarmglowMessages
  class UpsertWarmglowMessage < ApplicationCommand
    prepend SimpleCommand
    attr_reader :warmglow_messages_params

    def initialize(warmglow_messages_params)
      @warmglow_messages_params = warmglow_messages_params
    end

    def call
      if warmglow_messages_params[:id].present?
        update
      else
        create
      end
    end

    private

    def create
      WarmglowMessage.create!(warmglow_messages_params)
    end

    def update
      warmglow_messages = WarmglowMessage.find warmglow_messages_params[:id]
      warmglow_messages.update!(warmglow_messages_params)
      warmglow_messages
    end
  end
end
