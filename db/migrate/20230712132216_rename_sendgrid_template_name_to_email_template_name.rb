class RenameSendgridTemplateNameToEmailTemplateName < ActiveRecord::Migration[7.0]
  def change
    rename_column :email_logs, :sendgrid_template_name, :email_template_name
  end
end
