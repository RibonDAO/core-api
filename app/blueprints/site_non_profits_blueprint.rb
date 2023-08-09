class SiteNonProfitsBlueprint < Blueprinter::Base
  field(:main_image) do |object|
    ImagesHelper.image_url_for(object.main_image)
  end

  field(:logo) do |object|
    ImagesHelper.image_url_for(object.logo)
  end

  field :description do |non_profit|
    "#{I18n.t('impact_normalizer.donate')} #{Impact::Normalizer.new(
      non_profit,
      non_profit.impact_by_ticket
    ).normalize.join(' ')}"
  end
end
