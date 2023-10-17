module Donations
  class HandlePostDonationJob < ApplicationJob
    queue_as :default

    def perform(donation:)
      Events::Donations::SendDonationEventJob.perform_later(donation:)
      Donations::DecreasePoolBalanceJob.perform_later(donation:)
    rescue StandardError
      nil
    end
  end
end
