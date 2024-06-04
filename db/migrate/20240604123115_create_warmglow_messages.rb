class CreateWarmglowMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :warmglow_messages do |t|
      t.string :message
      t.integer :status, default: 0
      

      t.timestamps
    end
  end
end
