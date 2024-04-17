module Coupons
  class ClearExpiredCouponsJob < ApplicationJob
    queue_as :default

    def perform(coupon)
      ClearExpiredCoupons.call(coupon:)
    end
  end
end
