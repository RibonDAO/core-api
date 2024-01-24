class PopulateConfirmedAtAndRemoveColumsFromAccount < ActiveRecord::Migration[7.0]
   def change

 execute "UPDATE accounts
      SET confirmed_at = created_at
      WHERE provider IN ('apple', 'google')"

    remove_column :accounts, :confirmation_sent_at
    remove_column :accounts, :confirmation_token
    remove_column :accounts, :image
    remove_column :accounts, :name
    remove_column :accounts, :nickname
    remove_column :accounts, :remember_created_at
  end
end
