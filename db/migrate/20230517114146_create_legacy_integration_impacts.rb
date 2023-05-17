class CreateLegacyIntegrationImpacts < ActiveRecord::Migration[7.0]
  def change
    create_table :legacy_integration_impacts do |t|
      t.references :legacy_integration, foreign_key: true
      t.references :legacy_non_profit, foreign_key: true
      t.integer :total_donated_usd_cents
      t.string :total_impact
      t.integer :donations_count
      t.integer :donors_count
      t.date :reference_date

      t.timestamps
    end
  end
end
