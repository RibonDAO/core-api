class CreateDonationContributions < ActiveRecord::Migration[7.0]
  def change
    create_table :donation_contributions do |t|
      t.references :contribution, null: false, foreign_key: true
      t.references :donation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
