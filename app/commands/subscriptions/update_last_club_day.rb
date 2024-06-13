module Subscriptions
  class UpdateLastClubDay
    attr_reader :subscription

    def initialize(subscription:)
      @subscription = subscription
    end

    def call
      subscription.update!(last_club_day: 1.month.from_now)
    end
  end
end
