class AddUniqueAddressToIntegrations < ActiveRecord::Migration[7.0]
  def change
    add_column :integrations, :unique_address, :uuid, default: "gen_random_uuid()", null: false, unique: true
  end
end
