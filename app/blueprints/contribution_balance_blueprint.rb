class ContributionBalanceBlueprint < Blueprinter::Base
  identifier :id

  fields :created_at, :updated_at, :contribution_increased_amount_cents,
         :fees_balance_cents, :tickets_balance_cents
end
