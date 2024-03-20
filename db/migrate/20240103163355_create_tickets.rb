class CreateTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :external_id
      t.references :integration, null: false, foreign_key: true

      t.timestamps
    end
  end
end
