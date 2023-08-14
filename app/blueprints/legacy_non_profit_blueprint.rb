class LegacyNonProfitBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :impact_cost_ribons, :impact_cost_usd,
         :impact_description, :legacy_id, :current_id

  field(:logo_url) do |object|
    ImagesHelper.image_url_for(object.logo, variant: { resize_to_fit: [150, 150],
                                                       saver: { quality: 95 }, format: :jpg })
  end
end
