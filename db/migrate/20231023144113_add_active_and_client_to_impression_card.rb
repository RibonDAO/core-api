class AddActiveAndClientToImpressionCard < ActiveRecord::Migration[7.0]
  def change
    add_column :impression_cards, :active, :boolean, default: false
    add_column :impression_cards, :client, :string
  end
end
