class AddMetadataToIntegration < ActiveRecord::Migration[7.0]
  def change
    add_column :integrations, :metadata, :jsonb, default: {}
  end
end
