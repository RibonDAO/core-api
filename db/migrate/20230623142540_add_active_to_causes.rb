class AddActiveToCauses < ActiveRecord::Migration[7.0]
  def change
    add_column :causes, :active, :boolean
  end
end
