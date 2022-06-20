class RenameNationalIdInCustomers < ActiveRecord::Migration[7.0]
  def change
    rename_column :customers, :national_id, :tax_id
  end
end
