class AddSourceToTickets < ActiveRecord::Migration[7.0]
  def change
    add_column :tickets, :source, :integer, default: 0
    add_column :tickets, :status, :integer, default: 0
    add_column :tickets, :category, :integer, default: 0
  end
end
