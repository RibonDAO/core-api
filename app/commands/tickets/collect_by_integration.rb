# frozen_string_literal: true

module Tickets
  class CollectByIntegration < ApplicationCommand
    prepend SimpleCommand
    attr_reader :integration, :user, :platform, :ticket

    def initialize(integration:, user:, platform:)
      @integration = integration
      @user = user
      @platform = platform
    end

    def call
      with_exception_handle do
        transact_ticket if can_collect?
      end
    end

    private

    def transact_ticket
      ActiveRecord::Base.transaction do
        create_ticket
        create_user_integration_collected_ticket
      end
      delete_user_integration_collected_ticket if integration.ticket_availability_in_minutes.present?

      ticket
    end

    def can_collect?
      command = CanCollectByIntegration.call(integration:, user:)

      if command.success?
        can_collect = command.result
        errors.add(:message, I18n.t('tickets.blocked_message')) unless can_collect
        can_collect
      else
        errors.add_multiple_errors(command.errors)
        false
      end
    end

    def create_ticket
      @ticket = Ticket.create!(integration:, user:, platform:)
    end

    def create_user_integration_collected_ticket
      UserIntegrationCollectedTicket.create!(integration:, user:)
    end

    def delete_user_integration_collected_ticket
      ClearCollectedByIntegrationJob.set(wait_until:)
                                    .perform_later(integration, user)
    end

    def wait_until
      integration.ticket_availability_in_minutes.minutes.from_now
    end
  end
end
