class CreatePoolBalances < ActiveRecord::Migration[7.0]
  def change
    create_table :pool_balances do |t|
      t.references :pool, null: false, foreign_key: true
      t.decimal :balance

      t.timestamps
    end
  end
end
