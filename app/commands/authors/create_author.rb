# frozen_string_literal: true

module Authors
  class CreateAuthor < ApplicationCommand
    prepend SimpleCommand

    attr_reader :author_params

    def initialize(author_params)
      @author_params = author_params
    end

    def call
      with_exception_handle do
        author = Author.create!(author_params)

        author
      end
    end
  end
end
