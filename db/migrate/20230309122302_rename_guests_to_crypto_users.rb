class RenameGuestsToCryptoUsers < ActiveRecord::Migration[7.0]
  def change
    rename_table :guests, :crypto_users
  end
end
