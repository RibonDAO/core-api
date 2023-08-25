class AddSubscriptionToPersonPayments < ActiveRecord::Migration[7.0]
  def change
    add_reference :person_payments, :subscription, index: true, optional: true
  end
end
