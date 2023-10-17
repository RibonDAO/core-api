class ImpressionCardBlueprint < Blueprinter::Base
  identifier :id

  fields :headline, :title, :description, :cta_text, :cta_url, :video_url

  field(:image) do |object|
    ImagesHelper.image_url_for(object.image)
  end

  field(:with_video) do |object|
    object.video_url.present? && object.video_url != ''
  end
end
