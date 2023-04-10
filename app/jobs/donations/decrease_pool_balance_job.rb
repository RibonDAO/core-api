module Donations
  class DecreasePoolBalanceJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 3

    def perform(donation:)
      pool = donation.non_profit.cause.default_pool
      Service::Donations::PoolBalances.new(pool:).decrease_balance(donation.value / 100)
    end
  end
end
