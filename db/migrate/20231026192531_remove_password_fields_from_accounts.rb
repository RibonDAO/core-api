class RemovePasswordFieldsFromAccounts < ActiveRecord::Migration[7.0]
  def change
    remove_column :accounts, :encrypted_password
    remove_column :accounts, :allow_password_change
    remove_column :accounts, :reset_password_sent_at
    remove_column :accounts, :reset_password_token
  end
end
