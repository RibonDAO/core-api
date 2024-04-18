module Coupons
  class ClearExpiredCouponsJob < ApplicationJob
    queue_as :coupons

    def perform(coupon)
      ClearExpiredCoupons.call(coupon:)
    end
  end
end
