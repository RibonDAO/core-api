class UserLegacyImpactBlueprint < Blueprinter::Base
  fields :donations_count, :total_donated_usd, :total_impact,
         :created_at, :updated_at
  association :legacy_non_profit, blueprint: LegacyNonProfitBlueprint
end
