class AddPayerToPersonPayments < ActiveRecord::Migration[7.0]
  def change
    add_reference :person_payments, :payer, type: :uuid, polymorphic: true
  end
end
