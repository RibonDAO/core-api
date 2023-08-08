class ChangeOfferTypeOnSubscription < ActiveRecord::Migration[7.0]
  def up
    remove_column :subscriptions, :offer_id
    add_reference :subscriptions, :offer, index: true
  end
end
