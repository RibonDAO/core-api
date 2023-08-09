# frozen_string_literal: true

module Authors
  class UpdateAuthor < ApplicationCommand
    prepend SimpleCommand

    attr_reader :author_params

    def initialize(author_params)
      @author_params = author_params
    end

    def call
      with_exception_handle do
        author = Author.find author_params[:id]
        author.update(update_author_params)

        author
      end
    end

    private

    def update_author_params
      author_params
    end
  end
end
