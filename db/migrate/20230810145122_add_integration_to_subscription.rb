class AddIntegrationToSubscription < ActiveRecord::Migration[7.0]
  def change
    add_reference :subscriptions, :integration, foreign_key: true
  end
end
