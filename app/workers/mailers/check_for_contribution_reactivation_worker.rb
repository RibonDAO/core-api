# frozen_string_literal: true

module Mailers
  class CheckForContributionReactivationWorker
    include Sidekiq::Worker
    sidekiq_options queue: :mailers

    def perform(*_args)
      users = User.users_that_last_contributed_in(1.month.ago)

      users.each do |user|
        SendContributionReactivationEmailJob.perform_later(user:)
      end
    end
  end
end
