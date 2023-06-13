class StoryBlueprint < Blueprinter::Base
  identifier :id

  fields :updated_at, :created_at, :title, :description, :active, :position, :image_description

  field(:image) do |object|
    ImagesHelper.image_url_for(object.image, variant: { resize_to_fit: [800, 800],
                                                        saver: { quality: 95 }, format: :jpg })
  end

  view :minimal do
    excludes :created_at, :updated_at
  end
end
