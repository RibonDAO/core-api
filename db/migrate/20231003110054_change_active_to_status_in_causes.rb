class ChangeActiveToStatusInCauses < ActiveRecord::Migration[7.0]
  def up
    add_column :causes, :status, :integer

    # Migrate existing data
    execute <<-SQL
      UPDATE causes SET status = 0 WHERE active = false;
      UPDATE causes SET status = 1 WHERE active = true;
    SQL

    remove_column :causes, :active
  end

  def down
    add_column :causes, :active, :boolean

    # Migrate existing data
    execute <<-SQL
      UPDATE causes SET active = false WHERE status = 0;
      UPDATE causes SET active = true WHERE status = 1;
    SQL

    remove_column :causes, :status
  end
end
