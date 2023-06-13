class AddCurrencyOnPersonPayment < ActiveRecord::Migration[7.0]
  def change
    add_column :person_payments, :currency, :integer
  end
end
