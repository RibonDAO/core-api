# frozen_string_literal: true

module ImagesHelper
  def self.image_url_for(image, variant: nil)
    return url_with_cdn(image) if cdn_enabled?

    img = variant ? image.variant(variant) : image
    Rails.application.routes.url_helpers.polymorphic_url(img)
  rescue StandardError
    nil
  end

  def self.url_with_cdn(image)
    "#{cdn_url}#{image.key}"
  end

  def self.cdn_enabled?
    ENV.fetch('CDN_ENABLED', 'false') == 'true'
  end

  def self.cdn_url
    ENV.fetch('CDN_URL', nil)
  end
end
