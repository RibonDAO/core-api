class AddPlatformToPersonPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :person_payments, :platform, :string
    end
end
