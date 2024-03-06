# frozen_string_literal: true

module Tickets
  class CollectByClub < ApplicationCommand
    prepend SimpleCommand
    attr_reader :user, :platform, :tickets, :category

    def initialize(user:, platform:, category:)
      @user = user
      @platform = platform
      @category = category
    end

    def call
      tickets = user.tickets.where(source: :club, category:, status: :to_collect)
      with_exception_handle do
        ActiveRecord::Base.transaction do
          tickets.each do |ticket|
            ticket.update!(status: :collected)
          end
        end

        if tickets.length.positive?
          tickets
        else
          errors.add(:message, I18n.t('tickets.blocked_message'))
          false
        end
      end
    end
  end
end
