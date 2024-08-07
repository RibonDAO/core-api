class AddKindToNonProfits < ActiveRecord::Migration[7.0]
  def change
    add_column :non_profits, :kind, :integer, default: 0
  end
end
