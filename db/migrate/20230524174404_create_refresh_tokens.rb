class CreateRefreshTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :refresh_tokens do |t|
      t.string :crypted_token
      t.references :authenticatable, polymorphic: true, null: false

      t.timestamps
    end
    add_index :refresh_tokens, :crypted_token, unique: true
  end
end
