# frozen_string_literal: true

module Tickets
  class ClearCollectedByIntegration < ApplicationCommand
    prepend SimpleCommand

    attr_reader :integration, :user

    def initialize(integration:, user:)
      @integration = integration
      @user = user
    end

    def call
      with_exception_handle do
        UserIntegrationCollectedTicket.where(integration:, user:).delete_all
      end
    end
  end
end
