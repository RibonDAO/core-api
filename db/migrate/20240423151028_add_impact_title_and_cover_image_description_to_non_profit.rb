class AddImpactTitleAndCoverImageDescriptionToNonProfit < ActiveRecord::Migration[7.0]
  def change
    add_column :non_profits, :impact_title, :string, limit: 50
    add_column :non_profits, :cover_image_description, :text
  end
end
