module Legacy
  class CreateLegacyContributionsJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 1

    def perform(legacy_user, legacy_contribution)
      CreateLegacyContribution.call(legacy_user:, legacy_contribution:)
    end
  end
end
