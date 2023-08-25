class CreateSubscriptionsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.string :payment_method
      t.string :status
      t.references :offer, index: true, type: :uuid
      t.references :payer, index: true, type: :uuid, polymorphic: true
      t.references :receiver, index: true, type: :uuid, polymorphic: true
      t.string :external_id
      t.datetime :cancel_date
      t.string :platform

      t.timestamps
    end
  end
end
