class CreateBalanceHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :balance_histories do |t|
      t.date :date
      t.references :cause, null: false, foreign_key: true
      t.references :pool, null: false, foreign_key: true
      t.decimal :balance
      t.decimal :amount_donated

      t.timestamps
    end
  end
end
