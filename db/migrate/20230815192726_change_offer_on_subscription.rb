class ChangeOfferOnSubscription < ActiveRecord::Migration[7.0]
  def change
    remove_reference :subscriptions, :offer
    add_reference :subscriptions, :offer, foreign_key: true
  end
end
