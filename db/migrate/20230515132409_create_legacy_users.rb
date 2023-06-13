class CreateLegacyUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :legacy_users do |t|
      t.string :email
      t.references :user, foreign_key: true
      t.integer :legacy_id

      t.timestamps
    end
  end
end
