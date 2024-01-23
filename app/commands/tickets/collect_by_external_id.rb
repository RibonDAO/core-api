# frozen_string_literal: true

module Tickets
  class CollectByExternalId < ApplicationCommand
    prepend SimpleCommand
    attr_reader :integration, :user, :platform, :external_ids, :ticket, :voucher

    def initialize(integration:, user:, platform:, external_ids:)
      @integration = integration
      @user = user
      @platform = platform
      @external_ids = external_ids
    end

    def call
      tickets = []
      with_exception_handle do
        external_ids.each do |external_id|
          tickets << transact_ticket(external_id:) if can_collect?(external_id:)
        end
        if tickets.length.positive?
          tickets

        else
          errors.add(:message, I18n.t('tickets.blocked_message'))
          false
        end
      end
    end

    private

    def transact_ticket(external_id:)
      ActiveRecord::Base.transaction do
        create_voucher(external_id:)
        create_ticket(external_id:)
      end
      ticket
    end

    def can_collect?(external_id:)
      command = CanCollectByExternalId.call(external_id:)
      command.result
    end

    def create_ticket(external_id:)
      @ticket = Ticket.create!(integration:, user:, platform:, external_id:)
    end

    def create_voucher(external_id:)
      @voucher = Voucher.create!(external_id:, integration:)
    end
  end
end
