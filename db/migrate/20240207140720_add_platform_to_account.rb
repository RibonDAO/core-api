class AddPlatformToAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :platform, :string, default: nil, null: true
  end
end
