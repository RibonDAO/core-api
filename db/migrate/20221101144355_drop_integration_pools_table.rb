class DropIntegrationPoolsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :integration_pools
  end
end
