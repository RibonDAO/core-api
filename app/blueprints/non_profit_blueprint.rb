class NonProfitBlueprint < Blueprinter::Base
  identifier :id

  fields :updated_at, :created_at, :name, :wallet_address, :status

  association :cause, blueprint: CauseBlueprint, view: :minimal

  association :stories, blueprint: StoryBlueprint, view: :minimal

  association :non_profit_impacts, blueprint: NonProfitImpactsBlueprint

  field(:logo) do |object|
    ImagesHelper.image_url_for(object.logo, variant: { resize_to_fit: [150, 150],
                                                       saver: { quality: 95 }, format: :jpg })
  end

  field(:impact_description) do |object|
    object.impact_for&.impact_description || object.impact_description
  end

  field(:main_image) do |object|
    ImagesHelper.image_url_for(object.main_image, variant: { resize_to_fit: [450, 450],
                                                             saver: { quality: 95 }, format: :jpg })
  end

  field(:background_image) do |object|
    ImagesHelper.image_url_for(object.background_image)
  end

  field(:confirmation_image) do |object|
    ImagesHelper.image_url_for(object.confirmation_image)
  end

  field(:impact_by_ticket) do |object|
    object.impact_by_ticket
  end

  view :no_cause do
    excludes :cause
  end
end
