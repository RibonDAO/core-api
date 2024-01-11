# frozen_string_literal: true

module Tickets
  class ClearAllCollectedByIntegration < ApplicationCommand
    prepend SimpleCommand

    attr_reader :integration

    def initialize(integration:)
      @integration = integration
    end

    def call
      with_exception_handle do
        UserIntegrationCollectedTicket.where(integration:).delete_all
      end
    end
  end
end
