class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers, id: :uuid do |t|
      t.references :user
      t.string :name, null: false
      t.string :email, null: false, unique: true
      t.jsonb :customer_keys, default: {}
      t.string :national_id

      t.timestamps
    end

    remove_index :customers, :user_id
    add_index :customers, :user_id, unique: true
  end
end
