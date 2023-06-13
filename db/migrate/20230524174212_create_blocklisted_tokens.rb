class CreateBlocklistedTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :blocklisted_tokens do |t|
      t.string :jti
      t.references :authenticatable, polymorphic: true, null: false
      t.datetime :exp

      t.timestamps
    end
    add_index :blocklisted_tokens, :jti, unique: true
  end
end
