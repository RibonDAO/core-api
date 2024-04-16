# frozen_string_literal: true

module Tickets
  class CanCollectByCouponId < ApplicationCommand
    prepend SimpleCommand
    attr_reader :coupon_id, :user_id, :coupon

    def initialize(coupon_id:, user_id:)
      @coupon_id = coupon_id
      @user_id = user_id
      @coupon = Coupon.find(coupon_id)
    end

    def call
      with_exception_handle do
        valid_coupon_id?
      end
    end

    private

    def valid_coupon_id?
      check_coupon_expiration
      check_user_coupon
      check_coupon_availability
      true
    end

    def check_coupon_expiration
      raise I18n.t('tickets.coupon_expired') if coupon.expired?
    end

    def check_user_coupon
      raise I18n.t('tickets.coupon_already_collected') if UserCoupon.exists?(coupon_id:, user_id:)
    end

    def check_coupon_availability
      raise I18n.t('tickets.coupon_unavailable') if UserCoupon.where(coupon_id:).count >= coupon.available_quantity
    end
  end
end
