module Donations
  class GenerateBalanceHistoryJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 3

    def perform(pool:)
      DonationServices::PoolBalances.new(pool:).add_balance_history
    end
  end
end
