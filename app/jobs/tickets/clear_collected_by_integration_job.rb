module Tickets
  class ClearCollectedByIntegrationJob < ApplicationJob
    queue_as :tickets

    def perform(integration, user)
      ClearCollectedByIntegration.call(integration:, user:)
    end
  end
end
