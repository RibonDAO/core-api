class CreateUserIntegrationCollectedTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :user_integration_collected_tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :integration, null: false, foreign_key: true

      t.timestamps
    end
  end
end
