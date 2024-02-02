class AddCategoryToOffer < ActiveRecord::Migration[7.0]
  def change
    add_column :offers, :category, :integer, default: 0
  end
end
