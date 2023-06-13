class CreateContributions < ActiveRecord::Migration[7.0]
  def change
    create_table :contributions do |t|
      t.references :receiver, polymorphic: true, null: false

      t.timestamps
    end
  end
end
