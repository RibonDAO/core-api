# frozen_string_literal: true

module Tickets
  class GenerateClubTickets < ApplicationCommand
    prepend SimpleCommand

    attr_reader :user, :platform, :quantity, :category, :source

    def initialize(user:, platform:, quantity:, category:, source:)
      @user = user
      @platform = platform
      @quantity = quantity
      @category = category
      @source = source
    end

    def call
      with_exception_handle do
        transact_tickets
      end
    end

    def transact_tickets
      tickets = nil
      ActiveRecord::Base.transaction do
        tickets = create_tickets(build_tickets)
      end

      tickets
    end

    def build_tickets
      tickets_array = []
      quantity.times do |_index|
        tickets_array << { user:,
                           platform:, category:, status: :to_collect, source: }
      end

      tickets_array
    end

    private

    def create_tickets(tickets)
      Ticket.create!(tickets)
    end
  end
end
