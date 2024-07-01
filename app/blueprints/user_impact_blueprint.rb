class UserImpactBlueprint < Blueprinter::Base
  fields :impact, :donation_count
  association :non_profit, blueprint: NonProfitBlueprint
end
