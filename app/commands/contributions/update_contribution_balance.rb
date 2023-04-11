# frozen_string_literal: true

module Contributions
  class UpdateContributionBalance < ApplicationCommand
    prepend SimpleCommand

    attr_reader :contribution_balance, :fee_cents, :contribution_increased_amount_cents

    def initialize(contribution_balance:, fee_cents:, contribution_increased_amount_cents:)
      @contribution_balance = contribution_balance
      @fee_cents = fee_cents
      @contribution_increased_amount_cents = contribution_increased_amount_cents
    end

    def call
      contribution_balance.contribution_increased_amount_cents += contribution_increased_amount_cents
      contribution_balance.fees_balance_cents -= fee_cents
      contribution_balance.save
    end
  end
end
