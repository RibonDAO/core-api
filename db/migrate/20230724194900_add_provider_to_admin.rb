class AddProviderToAdmin < ActiveRecord::Migration[7.0]
  def change
    add_column :admins, :provider, :string
    add_column :admins, :uid, :string
  end
end
