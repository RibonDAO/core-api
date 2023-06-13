class CreateLegacyNonProfits < ActiveRecord::Migration[7.0]
  def change
    create_table :legacy_non_profits do |t|
      t.string :name
      t.string :logo_url
      t.integer :cost_of_one_impact
      t.string :impact_description
      t.integer :legacy_id
      t.integer :current_id

      t.timestamps
    end
  end
end
