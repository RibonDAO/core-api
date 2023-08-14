class ChangeStatusTypeOnSubscription < ActiveRecord::Migration[7.0]
  def change
    change_column :subscriptions, :status, :integer, using: 'status::integer'
  end
end
