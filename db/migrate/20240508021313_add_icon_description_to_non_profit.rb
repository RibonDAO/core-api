class AddIconDescriptionToNonProfit < ActiveRecord::Migration[7.0]
  def change
    add_column :non_profits, :icon_description, :string
  end
end
