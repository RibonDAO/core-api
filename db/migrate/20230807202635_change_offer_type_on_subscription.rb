class ChangeOfferTypeOnSubscription < ActiveRecord::Migration[7.0]
  def up
    remove_column :subscriptions, :offer_id
    execute <<-SQL
      ALTER TABLE subscriptions
      ADD COLUMN offer_id bigint REFERENCES offers(id);
    SQL
  end
end
