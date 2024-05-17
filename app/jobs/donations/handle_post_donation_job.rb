module Donations
  class HandlePostDonationJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 3

    def perform(donation:)
      Events::Donations::SendDonationEventJob.perform_later(donation:)
      Donations::DecreasePoolBalanceJob.perform_later(donation:)
      Users::IncrementDaysDonating.call(user: donation.user)
    rescue StandardError
      nil
    end
  end
end
