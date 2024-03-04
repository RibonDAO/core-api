# frozen_string_literal: true

module Tickets
  class GenerateClubTickets < ApplicationCommand
    prepend SimpleCommand

    attr_reader  :user, :platform, :quantity, :category

    def initialize(user:, platform:, quantity:, category:)
      @user = user
      @platform = platform
      @quantity = quantity
      @category = category
    end

    def call
      with_exception_handle do
        UserIntegrationCollectedTicket.where(integration:, user:).delete_all
      end
    end

    def build_tickets(integrations)
      tickets_array = []
      quantity.times do |index|
        tickets_array << { user_id: user.id,
                             platform:, category:, status: :pending  } # falta status ainda
      end

      tickets_array
    end

    private

    def create_tickets(tickets)
      Ticket.create!(tickets)
    end

  end
end
