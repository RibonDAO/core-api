class CreateCoupons < ActiveRecord::Migration[7.0]
  def change
    create_table :coupons,  id: :uuid do |t|
  
      t.integer :number_of_tickets

t.datetime :expiration_date

t.integer :available_quantity

t.string :reward_text

  t.timestamps
    end
  end
end
