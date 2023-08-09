class CreateLegacyContributions < ActiveRecord::Migration[7.0]
  def change
    create_table :legacy_contributions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :value
      t.datetime :day
      t.integer :legacy_payment_id
      t.integer :legacy_payment_platform
      t.integer :legacy_payment_method
      t.boolean :from_subscription

      t.timestamps
    end
  end
end
