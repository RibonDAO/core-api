class RemoveNotNullFromCustomerName < ActiveRecord::Migration[7.0]
  def change
    change_column_null :customers, :name, true
  end
end
