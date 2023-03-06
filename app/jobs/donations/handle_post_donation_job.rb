module Donations
  class HandlePostDonationJob < ApplicationJob
    queue_as :default

    def perform(donation:)
      Mailers::SendOneDonationEmailJob.perform_later(donation:)
      Mailers::SendDonationsEmailJob.perform_later(donation:)
    rescue StandardError
      nil
    end
  end
end
