# frozen_string_literal: true

module Tickets
  class CanCollectByCouponId < ApplicationCommand
    prepend SimpleCommand
    attr_reader :coupon_id, :user_id

    def initialize(coupon_id:, user_id:)
      @coupon_id = coupon_id
      @user_id = user_id
    end

    def call
      with_exception_handle do
        valid_coupon_id?
      end
    end

    private

    def valid_coupon_id?
      return false if coupon_id.blank?

      if Coupon.find(coupon_id).expired?
        errors.add(:message, I18n.t('tickets.coupon_expired'))
        return false
      end
      if UserCoupon.exists?(coupon_id:, user_id:)
        errors.add(:message, I18n.t('tickets.coupon_already_collected'))
        return false
      end
      true
    end
  end
end
