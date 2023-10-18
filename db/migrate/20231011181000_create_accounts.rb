class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.boolean :allow_password_change
      t.datetime :confirmation_sent_at
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.string :encrypted_password
      t.string :image
      t.string :name
      t.string :nickname
      t.string :provider
      t.datetime :remember_created_at
      t.datetime :reset_password_sent_at
      t.string :reset_password_token
      t.json :tokens
      t.string :uid
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
