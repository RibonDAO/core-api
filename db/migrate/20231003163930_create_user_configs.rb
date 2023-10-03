class CreateUserConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :user_configs do |t|
      t.boolean :allowed_email_marketing
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
