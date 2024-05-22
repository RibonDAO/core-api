module Managers
  module V1
    class TagsController < ManagersController
      def index
        @tags = Tag.all

        render json: TagBlueprint.render(@tags)
      end

      def create
        command = Tags::UpsertTag.call(tag_params)
        if command.success?
          render json: TagBlueprint.render(command.result), status: :created
        else
          render_errors(command.errors)
        end
      end

      def show
        @tag = Tag.find tag_params[:id]

        render json: TagBlueprint.render(@tag)
      end

      def update
        command = Tags::UpsertTag.call(tag_params)
        if command.success?
          render json: TagBlueprint.render(command.result), status: :ok
        else
          render_errors(command.errors)
        end
      end

      private

      def tag_params
        params.permit(:id, :name, :status, non_profit_tags_attributes: %i[non_profit_id _destroy])
      end
    end
  end
end
