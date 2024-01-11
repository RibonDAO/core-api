# frozen_string_literal: true

module Tickets
  class Donate < ApplicationCommand
    prepend SimpleCommand
    attr_reader :non_profit, :integration, :user, :platform, :quantity

    def initialize(integration:, non_profit:, user:, platform:, quantity:)
      @integration = integration
      @non_profit = non_profit
      @user = user
      @platform = platform
      @quantity = quantity
    end

    def call
      with_exception_handle do
        transact_donation if valid_dependencies?
      end
    end

    private

    def build_donations
      donations = []
      quantity.times do
        donations << { integration_id: integration.id, non_profit_id: non_profit.id, user_id: user.id,
                       platform:, value: ticket_value }
      end

      donations
    end

    def transact_donation
      donations = nil
      ActiveRecord::Base.transaction do
        destroy_tickets
        donations = create_donations(build_donations)
        update_user_donations_info
        label_donation(donations)
      end

      donations
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
      return true if user.tickets.count >= quantity && pool_balance?

      errors.add(:message, I18n.t('donations.blocked_message'))

      false
    end

    def destroy_tickets
      Ticket.where(user:).order(created_at: :asc).limit(quantity).destroy_all
    end

    def update_user_donations_info
      set_user_last_donation_at
      set_last_donated_cause
    end

    def create_donations(donations)
      Donation.create!(donations)
    end

    def set_user_last_donation_at
      Donations::SetUserLastDonationAt.call(user:, date_to_set: user.donations.last.created_at)
    end

    def set_last_donated_cause
      Donations::SetLastDonatedCause.call(user:, cause: non_profit.cause)
    end

    def label_donation(donations)
      return if RibonConfig.disable_labeling

      donations.each do |donation|
        Service::Contributions::TicketLabelingService.new(donation:).label_donation
      end
    end

    def ticket_value
      @ticket_value ||= RibonConfig.default_ticket_value
    end

    def pool
      non_profit.cause.default_pool
    end

    def pool_balance?
      return true if pool&.pool_balance.blank?

      pool.pool_balance.balance_for_donation?
    end
  end
end
