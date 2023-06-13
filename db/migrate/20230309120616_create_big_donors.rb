class CreateBigDonors < ActiveRecord::Migration[7.0]
  def change
    create_table :big_donors do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
