class CreateLegacyUserImpacts < ActiveRecord::Migration[7.0]
  def change
    create_table :legacy_user_impacts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :legacy_non_profit, null: false, foreign_key: true
      t.string :total_impact
      t.integer :total_donated_usd
      t.integer :donations_count

      t.timestamps
    end
  end
end
