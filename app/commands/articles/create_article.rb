# frozen_string_literal: true

module Articles
  class CreateArticle < ApplicationCommand
    prepend SimpleCommand

    attr_reader :article_params

    def initialize(article_params)
      @article_params = article_params
    end

    def call
      with_exception_handle do
        article = Article.create!(article_params)

        article
      end
    end
  end
end
