class RemoveDateFromBalanceHistory < ActiveRecord::Migration[7.0]
  def change
    remove_column :balance_histories, :date
  end
end
