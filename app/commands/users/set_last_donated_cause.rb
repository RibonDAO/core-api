# frozen_string_literal: true

module Users
  class SetLastDonatedCause
    prepend SimpleCommand

    attr_reader :user, :cause

    def initialize(user:, cause:)
      @user = user
      @cause = cause
    end

    def call
      user.create_user_donation_stats! unless user.user_donation_stats

      user.user_donation_stats.last_donated_cause = cause.id
      user.user_donation_stats.save
    end
  end
end
