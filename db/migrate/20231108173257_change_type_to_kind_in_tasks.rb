class ChangeTypeToKindInTasks < ActiveRecord::Migration[7.0]
  def change
    rename_column :tasks, :type, :kind
  end
end
