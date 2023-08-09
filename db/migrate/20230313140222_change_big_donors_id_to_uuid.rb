class ChangeBigDonorsIdToUuid < ActiveRecord::Migration[7.0]
  def change
    add_column :big_donors, :uuid, :uuid, default: "gen_random_uuid()", null: false

    change_table :big_donors do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE big_donors ADD PRIMARY KEY (id);"
  end
end
