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
        return unless user

        club_member?
      end
    end

    private

    def club_member?
      user.customers.any? do |customer|
        customer.subscriptions.active.any? { _1.offer.category == 'club' }
      end
    end
  end
end
