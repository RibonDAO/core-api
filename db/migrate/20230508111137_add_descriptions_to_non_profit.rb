class AddDescriptionsToNonProfit < ActiveRecord::Migration[7.0]
  def change
    add_column :non_profits, :logo_description, :string
    add_column :non_profits, :main_image_description, :string
    add_column :non_profits, :background_image_description, :string
    add_column :non_profits, :confirmation_image_description, :string
  end
end
