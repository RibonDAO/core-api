class CreateDonationContributions < ActiveRecord::Migration[7.0]
  def change
    drop_table :donation_contributions, if_exists: true
    
    create_table :donation_contributions do |t|
      t.references :contribution, null: false, foreign_key: true
      t.references :donation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
