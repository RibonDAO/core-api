module Tickets
  class ClearAllCollectedByIntegrationJob < ApplicationJob
    queue_as :tickets

    def perform(integration)
      ClearAllCollectedByIntegration.call(integration:)
    end
  end
end
