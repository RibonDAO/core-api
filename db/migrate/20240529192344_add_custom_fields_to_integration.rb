class AddCustomFieldsToIntegration < ActiveRecord::Migration[7.0]
  def change
    add_column :integrations, :onboarding_title, :string
    add_column :integrations, :onboarding_description, :text

    add_column :integrations, :banner_title, :string
    add_column :integrations, :banner_description, :text
  end
end
