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
      Subscription.where(payer_id: ids).active_from_club.to_a.size.positive?
    end
  end
end
