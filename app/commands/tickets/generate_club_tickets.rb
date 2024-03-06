# frozen_string_literal: true

module Tickets
  class GenerateClubTickets < ApplicationCommand
    prepend SimpleCommand

    attr_reader  :user, :platform, :quantity, :category, :integration

    def initialize(user:, platform:, quantity:, category:, integration:)
      @user = user
      @platform = platform
      @quantity = quantity
      @category = category
      @integration = integration
    end

    def call
      with_exception_handle do
        transact_donation
      end
    end

        def transact_donation
      ActiveRecord::Base.transaction do
      
        @tickets = create_tickets(build_tickets)
      
      end

      tickets
    end

    def build_tickets
      tickets_array = []
      quantity.times do |index|
        tickets_array << { user:,
                             platform:, category:, status: :to_collect, integration:  } # falta status ainda
      end

      tickets_array
    end

    private

    def create_tickets(tickets)
      Tickets.create!(tickets)
    end

  end
end
