module Coupons
  class ClearExpiredCouponsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :coupons

    def perform(*_args)
      expired_coupons = Coupon.where('expiration_date < ?', Time.zone.now)
      expired_coupons.each do |coupon|
        ClearExpiredCouponsJob.perform_later(coupon)
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
