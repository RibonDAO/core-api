# replaced by the batch

module Donations
  class RetryDonationsJob < ApplicationJob
    queue_as :default

    def perform
      UpdateProcessingDonations.call
      UpdateFailedDonations.call
    end
  end
end
