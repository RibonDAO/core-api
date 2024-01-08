class AddPlatformToTickets < ActiveRecord::Migration[7.0]
  def change
    add_column :tickets, :platform, :string
  end
end
