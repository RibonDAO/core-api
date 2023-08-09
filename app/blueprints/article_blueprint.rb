class ArticleBlueprint < Blueprinter::Base
  include ActionView::Helpers::DateHelper

  identifier :id

  fields :updated_at, :created_at, :title, :published_at, :visible, :link, :language

  field(:image_url) do |object|
    ImagesHelper.image_url_for(object.image)
  end

  field(:published_at_in_words) do |object|
    if Time.zone.now > object.published_at
      I18n.t('date.past', date: Formatters::Date.in_words_for(object.published_at))
    else
      I18n.t('articles.not_published_yet')
    end
  end

  association :author, blueprint: AuthorBlueprint, view: :minimal
end
