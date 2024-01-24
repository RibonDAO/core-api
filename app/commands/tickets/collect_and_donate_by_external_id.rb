# frozen_string_literal: true

module Tickets
  class CollectAndDonateByExternalId < ApplicationCommand
    prepend SimpleCommand
    attr_reader :integration, :user, :platform, :non_profit, :external_ids, :donation

    def initialize(integration:, user:, platform:, non_profit:, external_ids:)
      @integration = integration
      @user = user
      @platform = platform
      @non_profit = non_profit
      @external_ids = external_ids
    end

    def call
      with_exception_handle do
        transact_donation if valid_dependencies?
      end
    end

    private

    def transact_donation
      ActiveRecord::Base.transaction do
        @donation = collect_ticket
      end

      donation
    end

    def valid_dependencies?
      valid_user? && valid_non_profit?
    end

    def valid_user?
      errors.add(:message, I18n.t('donations.user_not_found')) unless user

      user
    end

    def valid_non_profit?
      errors.add(:message, I18n.t('donations.non_profit_not_found')) unless non_profit

      non_profit
    end

    def collect_ticket
      command = CollectByExternalId.call(integration:, user:, platform:, external_ids:)

      if command.success?
        donate_ticket
      else
        errors.add(:message, I18n.t('tickets.blocked_message'))
      end
    end

    def donate_ticket
      command = Donate.call(non_profit:, user:, platform:, quantity: 1)

      if command.success?
        command.result.first
      else
        errors.add_multiple_errors(command.errors)
      end
    end
  end
end
