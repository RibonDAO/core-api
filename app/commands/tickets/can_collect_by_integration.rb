# frozen_string_literal: true

module Tickets
  class CanCollectByIntegration < ApplicationCommand
    prepend SimpleCommand
    attr_reader :integration, :user

    def initialize(integration:, user:)
      @integration = integration
      @user = user
    end

    def call
      with_exception_handle do
        valid_dependencies?
      end
    end

    private

    def valid_dependencies?
      valid_user? && valid_integration? && allowed?
    end

    def valid_user?
      errors.add(:message, I18n.t('tickets.user_not_found')) unless user

      user
    end

    def valid_integration?
      errors.add(:message, I18n.t('tickets.integration_not_found')) unless integration

      integration
    end

    def allowed?
      return true unless UserIntegrationCollectedTicket.where(integration:, user:).first

      false
    end
  end
end
