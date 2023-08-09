class CreateEmailLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :email_logs do |t|
      t.string :sendgrid_template_name
      t.integer :email_type
      t.integer :status
      t.references :receiver, type: :string, polymorphic: true, null: false

      t.timestamps
    end
  end
end
