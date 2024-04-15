# frozen_string_literal: true

module Tickets
  class CollectByCouponId < ApplicationCommand
    prepend SimpleCommand
    attr_reader :user, :platform, :coupon_id, :ticket, :coupon

    def initialize(user:, platform:, coupon_id:)
      @user = user
      @platform = platform
      @coupon_id = coupon_id
    end

    def call
      with_exception_handle do
        check_coupon
        ticket = transact_ticket if can_collect?

        return false unless ticket

        { ticket:, reward_text: coupon.reward_text }
      end
    end

    private

    def check_coupon
      @coupon = Coupon.find(coupon_id)
      return true if coupon

      errors.add(:message, I18n.t('tickets.coupon_invalid'))
      false
    end

    def transact_ticket
      ActiveRecord::Base.transaction do
        create_user_coupon
        create_ticket
      end
      ticket
    end

    def can_collect?
      command = CanCollectByCouponId.call(coupon_id:, user_id: user.id)
      if command.success?
        command.result
      else
        errors.add_multiple_errors(command.errors)
        false
      end
    end

    def create_ticket
      @ticket = Ticket.create!(user:, platform:, external_id: coupon_id, source: :coupon,
                               status: :collected, category: :extra)
    end

    def create_user_coupon
      UserCoupon.create!(coupon:, user:, platform:)
    end
  end
end
