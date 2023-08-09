class ChangeExternalIdOnSubscription < ActiveRecord::Migration[7.0]
  def change
    rename_column :subscriptions, :external_id, :external_subscription_id
  end
end
