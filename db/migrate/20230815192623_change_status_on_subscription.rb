class ChangeStatusOnSubscription < ActiveRecord::Migration[7.0]
  def change
    remove_column :subscriptions, :status, :integer
    add_column :subscriptions, :status, :integer
  end
end
