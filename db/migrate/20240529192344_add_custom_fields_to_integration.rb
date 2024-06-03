class AddCustomFieldsToIntegration < ActiveRecord::Migration[7.0]
  def change
    add_column :integrations, :onboarding_title, :string
    add_column :integrations, :onboarding_description, :text

    add_column :integrations, :banner_title, :string
    add_column :integrations, :banner_description, :text

    add_column :integrations, :no_tickets_title, :string
    add_column :integrations, :no_tickets_cta_text, :string
    add_column :integrations, :no_tickets_cta_url, :string
  end
end
