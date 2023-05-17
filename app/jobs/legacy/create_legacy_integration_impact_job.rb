module Legacy
  class CreateLegacyIntegrationImpactJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 1

    def perform(_legacy_integration, legacy_impacts)
      CreateLegacyIntegrationImpact.call(legacy_user:, legacy_impacts:)
    end
  end
end
