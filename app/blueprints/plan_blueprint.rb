class PlanBlueprint < Blueprinter::Base
  identifier :id

  fields :daily_tickets, :monthly_tickets, :status

  association :offer, blueprint: OfferBlueprint
end
