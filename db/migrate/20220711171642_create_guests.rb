class CreateGuests < ActiveRecord::Migration[7.0]
  def change
    create_table :guests, id: :uuid do |t|
      t.string :wallet_address, null: false
    end
  end
end
