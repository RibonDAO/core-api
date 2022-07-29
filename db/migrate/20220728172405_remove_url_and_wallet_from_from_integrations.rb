class RemoveUrlAndWalletFromFromIntegrations < ActiveRecord::Migration[7.0]
  def change
    remove_column :integrations, :url
    remove_column :integrations, :wallet_address
  end
end
