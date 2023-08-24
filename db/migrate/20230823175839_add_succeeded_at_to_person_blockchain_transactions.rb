class AddSucceededAtToPersonBlockchainTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :person_blockchain_transactions, :succeeded_at, :datetime
  end
end
