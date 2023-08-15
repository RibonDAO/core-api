class ChangeReceiverTypeOnSubscription < ActiveRecord::Migration[7.0]
  def change
    remove_reference :subscriptions, :receiver, polymorphic: true, optional: true
    add_reference :subscriptions, :receiver, polymorphic: true, optional: true
  end
end
