class LegacyNonProfitBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :logo_url, :impact_cost_ribons, :impact_cost_usd,
         :impact_description, :legacy_id, :current_id
end
