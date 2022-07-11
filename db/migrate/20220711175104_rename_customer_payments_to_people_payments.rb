class RenameCustomerPaymentsToPeoplePayments < ActiveRecord::Migration[7.0]
  def change
    rename_table :customer_payments, :people_payments
  end
end
