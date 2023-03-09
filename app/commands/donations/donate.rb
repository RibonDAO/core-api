# frozen_string_literal: true

module Donations
  class Donate < ApplicationCommand
    prepend SimpleCommand
    attr_reader :non_profit, :integration, :donation, :user, :platform

    def initialize(integration:, non_profit:, user:, platform:)
      @integration = integration
      @non_profit = non_profit
      @user = user
      @platform = platform
    end

    def call
      with_exception_handle do
        transact_donation if valid_dependencies?
      end
    end

    private

    def transact_donation
      create_donation
      set_user_last_donation_at
      set_last_donated_cause

      donation
    end

    def valid_dependencies?
      valid_user? && valid_integration? && valid_non_profit? && allowed?
    end

    def valid_user?
      errors.add(:message, I18n.t('donations.user_not_found')) unless user

      user
    end

    def valid_integration?
      errors.add(:message, I18n.t('donations.integration_not_found')) unless integration

      integration
    end

    def valid_non_profit?
      errors.add(:message, I18n.t('donations.non_profit_not_found')) unless non_profit

      non_profit
    end

    def allowed?
      return true if user.can_donate?(integration)

      errors.add(:message, I18n.t('donations.blocked_message'))

      false
    end

    def create_donation
      @donation = Donation.create!(integration:, non_profit:, user:, value: ticket_value, platform:)
    end

    def set_user_last_donation_at
      SetUserLastDonationAt.call(user:, date_to_set: donation.created_at)
    end

    def set_last_donated_cause
      SetLastDonatedCause.call(user:, cause: non_profit.cause)
    end

    def ticket_value
      @ticket_value ||= RibonConfig.default_ticket_value
    end
  end
end
