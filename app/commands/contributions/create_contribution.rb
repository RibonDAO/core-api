# frozen_string_literal: true

module Contributions
  class CreateContribution < ApplicationCommand
    prepend SimpleCommand
    attr_reader :payment

    CONTRACT_FEE_PERCENTAGE = 0.1

    def initialize(payment:)
      @payment = payment
    end

    def call
      Contribution.create!(person_payment: payment, receiver: payment.receiver,
                           generated_fee_cents: payment.usd_value_cents * CONTRACT_FEE_PERCENTAGE)
    rescue StandardError => e
      errors.add(:message, e.message)
      Reporter.log(error: e)
    end
  end
end
