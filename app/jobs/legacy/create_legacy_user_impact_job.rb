module Legacy
  class CreateLegacyUserImpactJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 3

    def perform(email:, impacts:, legacy_id:)
      CreateLegacyUserImpact.new(email:, impacts:, legacy_id:).call
    end
  end
end
