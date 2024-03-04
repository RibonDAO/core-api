class AddSourceToDonations < ActiveRecord::Migration[7.0]
  def change
    add_column :donations, :source, :integer, default: 0
    add_column :donations, :category, :integer, default: 0
  end
end
