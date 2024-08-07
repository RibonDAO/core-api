class IntegrationBlueprint < Blueprinter::Base
  identifier :id

  fields :updated_at, :created_at, :name, :unique_address, :status, :integration_address,
         :ticket_availability_in_minutes, :webhook_url, :integration_dashboard_address,
         :onboarding_title, :onboarding_description, :banner_title, :banner_description

  field(:logo) do |object|
    metadata = object.metadata

    metadata['profile_photo'] || ImagesHelper.image_url_for(object.logo)
  end

  field(:onboarding_image) do |object|
    ImagesHelper.image_url_for(object.onboarding_image)
  end

  association :integration_wallet, blueprint: IntegrationWalletBlueprint

  association :integration_task, blueprint: IntegrationTaskBlueprint

  view :manager do
    field :integration_deeplink_address
  end

  field :metadata do |object|
    metadata = object.metadata

    metadata if metadata['branch'] == 'referral'
  end

  view :minimal do
    excludes :integration_wallet, :integration_task, :metadata,
             :integration_dashboard_address,
             :unique_address, :created_at, :updated_at
  end
end
