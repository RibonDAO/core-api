class LegacyNonProfitBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :logo_url, :cost_of_one_impact,
         :impact_description, :legacy_id, :current_id
end
