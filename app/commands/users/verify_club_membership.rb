# frozen_string_literal: true

module Users
  class VerifyClubMembership < ApplicationCommand
    prepend SimpleCommand

    attr_reader :user

    def initialize(user:)
      @user = user
    end

    def call
      with_exception_handle do
        return false unless user

        club_member?
      end
    end

    private

    def club_member?
      ids = user.customers.pluck(:id)
      Subscription.joins(:offer)
                  .where(payer_id: ids, status: :active, offer: { category: :club })
                  .count.positive?
    end
  end
end
