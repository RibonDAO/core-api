class CreateUserTasksStatistics < ActiveRecord::Migration[7.0]
  def change
    create_table :user_tasks_statistics do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :first_completed_all_tasks_at, default: nil
      t.integer :streak, default: 0

      t.timestamps
    end
  end
end
