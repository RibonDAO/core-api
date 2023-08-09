class CreateUserCompletedTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :user_completed_tasks, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true
      t.string :task_identifier, null: false
      t.datetime :last_completed_at, null: false
      t.integer :times_completed, null: false, default: 0
      t.timestamps
    end
  end
end
