module Donations
  class HandlePostDonationJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 3

    def perform(donation:)
      Users::UpdateDonationStatsJob.perform_later(donation:)
      Events::Donations::SendDonationEventJob.perform_later(donation:)
      Donations::DecreasePoolBalanceJob.perform_later(donation:)
    rescue StandardError
      nil
    end
  end
end
