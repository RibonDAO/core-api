# frozen_string_literal: true

module Articles
  class UpdateArticle < ApplicationCommand
    prepend SimpleCommand

    attr_reader :article_params

    def initialize(article_params)
      @article_params = article_params
    end

    def call
      with_exception_handle do
        article = Article.find article_params[:id]
        article.update(update_article_params)

        article
      end
    end

    private

    def update_article_params
      article_params
    end
  end
end
