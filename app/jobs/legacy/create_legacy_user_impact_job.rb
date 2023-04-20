module Legacy
  class CreateLegacyUserImpactJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 3

    def perform(user:, impacts:)
      CreateLegacyUserImpact.new(legacy_user: user, impacts:).call
    end
  end
end
