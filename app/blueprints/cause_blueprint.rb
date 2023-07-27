class CauseBlueprint < Blueprinter::Base
  identifier :id

  fields :updated_at, :created_at, :name, :active, :main_image_description, :cover_image_description,
         :pool_balance

  association :pools, blueprint: PoolBlueprint

  association :non_profits, blueprint: NonProfitBlueprint, view: :no_cause

  field(:main_image) do |object|
    ImagesHelper.image_url_for(object.main_image)
  end

  field(:cover_image) do |object|
    ImagesHelper.image_url_for(object.cover_image)
  end

  view :data_and_images do
    excludes :non_profits
  end

  view :minimal do
    excludes :created_at, :updated_at, :non_profits, :pools, :main_image,
             :main_image_description, :cover_image, :cover_image_description
  end

  field(:default_pool) do |object|
    object.default_pool&.address
  end
end
