module Managers
  module V1
    module News
      class AuthorsController < ManagersController
        def index
          @authors = Author.all

          render json: AuthorBlueprint.render(@authors)
        end

        def show
          @author = Author.find(params[:id])

          render json: AuthorBlueprint.render(@author)
        end

        def create
          command = Authors::CreateAuthor.call(author_params)
          if command.success?
            render json: AuthorBlueprint.render(command.result), status: :created
          else
            render_errors(command.errors)
          end
        end

        def update
          command = Authors::UpdateAuthor.call(author_params.merge(id: params[:id]))
          if command.success?
            render json: AuthorBlueprint.render(command.result)
          else
            render_errors(command.errors)
          end
        end

        private

        def author_params
          params.permit(:name)
        end
      end
    end
  end
end
