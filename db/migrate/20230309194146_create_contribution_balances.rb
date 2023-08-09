class CreateContributionBalances < ActiveRecord::Migration[7.0]
  def change
    create_table :contribution_balances do |t|
      t.references :contribution, null: false, foreign_key: true
      t.integer :tickets_balance_cents
      t.integer :fees_balance_cents
      t.integer :total_fees_increased_cents

      t.timestamps
    end
  end
end
