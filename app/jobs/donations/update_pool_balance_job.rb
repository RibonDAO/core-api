module Donations
  class UpdatePoolBalanceJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 3

    def perform(pool:)
      Service::Donations::PoolBalances.new(pool:).update_balance
    end
  end
end
