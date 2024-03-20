module Managers
  module V1
    class TasksController < ManagersController
      def index
        @tasks = Task.all

        render json: TaskBlueprint.render(@tasks)
      end

      def create
        @task = Task.new(task_params)

        if @task.save
          render json: TaskBlueprint.render(@task), status: :created
        else
          head :unprocessable_entity
        end
      end

      def show
        @task = Task.find(params[:id])

        render json: TaskBlueprint.render(@task)
      end

      def update
        @task = Task.find(params[:id])

        if @task.update(task_params)
          render json: TaskBlueprint.render(@task), status: :ok
        else
          head :unprocessable_entity
        end
      end

      def destroy
        @task = Task.find(params[:id])

        if @task.destroy
          head :no_content
        else
          head :unprocessable_entity
        end
      end

      private

      def task_params
        params.permit(:id, :title, :actions, :kind, :navigation_callback, :visibility, :client)
      end
    end
  end
end
