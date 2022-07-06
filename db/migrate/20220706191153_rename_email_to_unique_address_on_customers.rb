class RenameEmailToUniqueAddressOnCustomers < ActiveRecord::Migration[7.0]
  def change
    rename_column :customers, :email, :unique_address
  end
end
