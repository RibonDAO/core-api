class FixTotalFeesIncreasedCentsName < ActiveRecord::Migration[7.0]
  def change
    rename_column :contribution_balances, :total_fees_increased_cents, :contribution_increased_amount_cents
  end
end
