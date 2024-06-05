module Donations
  class UpdatePoolBalanceJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 3

    def perform
      Pool.all.each do |pool|
        SleeperHelper.sleep(1)
        Service::Donations::PoolBalances.new(pool:).update_balance
      end
    end
  end
end
