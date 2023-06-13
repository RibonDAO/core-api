class AddImpactCostRibonsToLegacyNonProfit < ActiveRecord::Migration[7.0]
  def change
    rename_column :legacy_non_profits, :cost_of_one_impact, :impact_cost_ribons
    add_column :legacy_non_profits, :impact_cost_usd, :decimal
  end
end
