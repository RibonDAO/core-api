class CreateLegacyIntegrations < ActiveRecord::Migration[7.0]
  def change
    create_table :legacy_integrations do |t|
      t.string :name
      t.references :integration, foreign_key: true
      t.integer :total_donors
      t.bigint :legacy_id

      t.timestamps
    end
  end
end
