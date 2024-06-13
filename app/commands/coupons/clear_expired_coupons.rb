# frozen_string_literal: true

module Coupons
  class ClearExpiredCoupons < ApplicationCommand
    prepend SimpleCommand

    attr_reader :coupon

    def initialize(coupon:)
      @coupon = coupon
    end

    def call
      with_exception_handle do
        transact_expired_coupon(coupon)
      end
    end

    private

    def transact_expired_coupon(coupon)
      users_coupons = UserCoupon.where(coupon_id: coupon.id)
      users_coupons.each do |user_coupon|
        move_to_expired(user_coupon)
      end
    end

    def move_to_expired(user_coupon)
      UserExpiredCoupon.create!(
        user_id: user_coupon.user_id,
        coupon_id: user_coupon.coupon_id
      )
      user_coupon.destroy
    end
  end
end
