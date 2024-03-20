class AddDeleteAtToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :deleted_at, :datetime
  end
end
