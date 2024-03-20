module Api
  module V1
    class TasksController < ApplicationController
      def index
        @tasks = Task.where(client: task_params[:client] || 'web')

        render json: TaskBlueprint.render(@tasks)
      end

      private

      def task_params
        params.permit(:client)
      end
    end
  end
end
