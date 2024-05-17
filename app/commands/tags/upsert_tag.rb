module Tags
  class UpsertTag < ApplicationCommand
    prepend SimpleCommand
    attr_reader :tag_params

    def initialize(tag_params)
      @tag_params = tag_params
    end

    def call
      if tag_params[:id].present?
        update
      else
        create
      end
    end

    private

    def create
      Tag.create!(tag_params)
    end

    def update
      tag = Tag.find tag_params[:id]
      tag.non_profit_tags.clear if tag_params[:non_profit_tags_attributes].present?
      tag.update!(tag_params)
      tag
    end
  end
end
