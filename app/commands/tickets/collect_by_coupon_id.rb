# frozen_string_literal: true

module Tickets
  class CollectByCouponId < ApplicationCommand
    prepend SimpleCommand
    attr_reader :user, :platform, :coupon_id, :tickets, :coupon

    def initialize(user:, platform:, coupon_id:)
      @user = user
      @platform = platform
      @coupon_id = coupon_id
    end

    def call
      with_exception_handle do
        check_coupon
        transact_ticket if can_collect?

        return false unless tickets

        { tickets:, coupon: }
      end
    end

    private

    def check_coupon
      @coupon = Coupon.where(id: coupon_id).first
      return if coupon

      raise I18n.t('tickets.coupon_invalid')
    end

    def transact_ticket
      ActiveRecord::Base.transaction do
        create_user_coupon
        create_ticket
      end
    end

    def can_collect?
      command = CanCollectByCouponId.call(coupon_id:, user_id: user&.id)
      if command.success?
        command.result
      else
        errors.add_multiple_errors(command.errors)
        false
      end
    end

    def build_tickets
      tickets_array = []

      coupon.number_of_tickets.times do |_index|
        tickets_array << { user:, platform:, external_id: coupon_id, source: :coupon,
                           status: :collected, category: :extra }
      end

      tickets_array
    end

    def create_ticket
      @tickets = Ticket.create!(build_tickets)
    end

    def create_user_coupon
      UserCoupon.create!(coupon:, user:, platform:)
    end
  end
end
