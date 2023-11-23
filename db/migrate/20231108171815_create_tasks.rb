class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    drop_table :tasks, if_exists: true
    create_table :tasks, id: :uuid do |t|
      t.string :title, null: false
      t.string :actions, null: false
      t.string :type, default: 'daily'
      t.string :navigation_callback
      t.string :visibility, default: 'visible'
      t.string :client, default: 'web'

      t.timestamps
    end
  end
end
