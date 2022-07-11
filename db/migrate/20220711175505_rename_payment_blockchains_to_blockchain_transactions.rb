class RenamePaymentBlockchainsToBlockchainTransactions < ActiveRecord::Migration[7.0]
  def change
    rename_table :customer_payment_blockchains, :people_blockchain_transactions
  end
end
