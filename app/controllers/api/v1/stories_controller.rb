module Api
  module V1
    class StoriesController < ApplicationController
      def index
        @stories = Story.all

        render json: StoryBlueprint.render(@stories, view: :minimal)
      end

      def create
        command = Stories::CreateStory.call(story_params)
        if command.success?
          render json: StoryBlueprint.render(command.result, view: :minimal), status: :created
        else
          render_errors(command.errors)
        end
      end

      def show
        @story = Story.find(story_params[:id])

        render json: StoryBlueprint.render(@story, view: :minimal)
      end

      def update
        command = Stories::UpdateStory.call(story_params)
        if command.success?
          render json: StoryBlueprint.render(command.result), status: :ok
        else
          render_errors(command.errors)
        end
      end

      def destroy
        @story = Story.find(story_params[:id])

        @story.destroy
      end

      private

      def story_params
        params.permit(:id, :title, :description, :position, :active, :image, :image_description)
      end
    end
  end
end
