class CreatePlans < ActiveRecord::Migration[7.0]
  def change
    create_table :plans do |t|
      t.integer :daily_tickets
      t.integer :monthly_tickets
      t.integer :status
      t.references :offer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
