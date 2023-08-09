class AddFieldsToPersonPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :person_payments, :crypto_value_cents, :integer
    add_column :person_payments, :liquid_value_cents, :integer
  end
end
