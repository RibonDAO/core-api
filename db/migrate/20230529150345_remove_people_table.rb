class RemovePeopleTable < ActiveRecord::Migration[7.0]
  def change
    remove_reference :crypto_users, :person, index: true
    remove_reference :customers, :person, index: true
    remove_reference :person_payments, :person, index: true
    drop_table :people
  end
end
