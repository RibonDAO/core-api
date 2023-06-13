module Legacy
  class CreateLegacyUserImpactJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 1

    def perform(legacy_user, legacy_impacts)
      CreateLegacyUserImpact.call(legacy_user:, legacy_impacts:)
    end
  end
end
