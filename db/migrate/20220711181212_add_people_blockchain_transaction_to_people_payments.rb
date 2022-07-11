class AddPeopleBlockchainTransactionToPeoplePayments < ActiveRecord::Migration[7.0]
  def change
    remove_reference :people_blockchain_transactions, :customer_payment
    add_reference :people_blockchain_transactions, :people_payment, foreign_key: true
  end
end
