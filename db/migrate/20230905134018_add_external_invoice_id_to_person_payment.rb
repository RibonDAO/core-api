class AddExternalInvoiceIdToPersonPayment < ActiveRecord::Migration[7.0]
  def change
    add_column :person_payments, :external_invoice_id, :string
  end
end
