class CreateAllowlistedTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :allowlisted_tokens do |t|
      t.string :jti
      t.references :authenticatable, polymorphic: true, null: false
      t.datetime :exp

      t.timestamps
    end
    add_index :allowlisted_tokens, :jti, unique: true
  end
end
