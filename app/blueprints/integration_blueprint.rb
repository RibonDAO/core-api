class IntegrationBlueprint < Blueprinter::Base
  identifier :id

  fields :updated_at, :created_at, :name, :unique_address, :status, :integration_address,
         :ticket_availability_in_minutes, :webhook_url, :integration_dashboard_address,
         :integration_deeplink_address

  field(:logo) do |object|
    ImagesHelper.image_url_for(object.logo)
  end

  association :integration_wallet, blueprint: IntegrationWalletBlueprint

  association :integration_task, blueprint: IntegrationTaskBlueprint
end
