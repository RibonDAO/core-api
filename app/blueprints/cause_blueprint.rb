class CauseBlueprint < Blueprinter::Base
  identifier :id

  fields :updated_at, :created_at, :name, :active

  association :pools, blueprint: PoolBlueprint

  association :non_profits, blueprint: NonProfitBlueprint, view: :no_cause

  field(:main_image) do |object|
    ImagesHelper.image_url_for(object.main_image)
  end

  field(:cover_image) do |object|
    ImagesHelper.image_url_for(object.cover_image)
  end

  view :minimal do
    excludes :created_at, :updated_at
  end

  field(:default_pool) do |object|
    object.default_pool&.address
  end
end
