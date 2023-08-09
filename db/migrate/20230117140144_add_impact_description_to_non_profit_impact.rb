class AddImpactDescriptionToNonProfitImpact < ActiveRecord::Migration[7.0]
  def change
    add_column :non_profit_impacts, :impact_description, :text
  end
end
