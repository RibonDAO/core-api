class AddNextPaymentOnSubscription < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :next_payment_attempt, :datetime
  end
end
