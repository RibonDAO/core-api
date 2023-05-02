# frozen_string_literal: true

module Contributions
  class CreateNonFeeableContribution < ApplicationCommand
    prepend SimpleCommand
    attr_reader :payment

    def initialize(payment:)
      @payment = payment
    end

    def call
      ActiveRecord::Base.transaction do
        contribution = Contribution.create!(person_payment: payment, receiver: payment.receiver,
                                            generated_fee_cents: 0)
        contribution.set_contribution_balance
      end
    rescue StandardError => e
      errors.add(:message, e.message)
      Reporter.log(error: e)
    end
  end
end
