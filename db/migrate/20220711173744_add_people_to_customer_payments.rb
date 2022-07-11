class AddPeopleToCustomerPayments < ActiveRecord::Migration[7.0]
  def change
    remove_reference :customer_payments, :customer
    add_reference :customer_payments, :people, foreign_key: true, type: :uuid
  end
end
