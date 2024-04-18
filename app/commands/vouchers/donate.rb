# frozen_string_literal: true

module Vouchers
  class Donate < ApplicationCommand
    prepend SimpleCommand
    attr_reader :donation_command, :integration, :external_id, :voucher

    def initialize(donation_command:, integration:, external_id:)
      @donation_command = donation_command
      @integration = integration
      @external_id = external_id
      @voucher = Voucher.new(integration:, external_id:)
    end

    def call
      with_exception_handle do
        if voucher.valid?
          command = call_donation_command
          if command.success?
            @voucher = create_voucher(command.result)
            call_webhook
          end

          voucher
        else
          errors.add(:message, I18n.t('donations.invalid_voucher'))
        end
      end
    end

    private

    def call_donation_command
      donation_command.call
    end

    def create_voucher(donation)
      Voucher.create(external_id:, integration:, donation:)
    end

    def call_webhook
      WebhookJob.perform_later(voucher) if integration.webhook_url
    end
  end
end
