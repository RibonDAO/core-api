class AddPlatformToDonations < ActiveRecord::Migration[7.0]
  def change
    add_column :donations, :platform, :string
  end
end
