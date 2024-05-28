# frozen_string_literal: true

module Users
  class SetUserLastDonationAt
    prepend SimpleCommand

    attr_reader :user, :date_to_set

    def initialize(user:, date_to_set:)
      @user = user
      @date_to_set = date_to_set
    end

    def call
      user.create_user_donation_stats! unless user.user_donation_stats

      user.user_donation_stats.last_donation_at = date_to_set
      user.user_donation_stats.save
    end
  end
end
