class CreateReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports do |t|
      t.string :name
      t.string :link
      t.boolean :active

      t.timestamps
    end
  end
end
