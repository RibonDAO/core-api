module Api
  module V1
    class UsersController < ApplicationController
      def search
        @user = User.find_by(email: params[:email])

        if @user
          render json: UserBlueprint.render(@user, view: :extended)
        else
          render json: { error: 'user not found' }, status: :not_found
        end
      end

      def create
        @user = User.new(user_params)

        if @user.save
          render json: UserBlueprint.render(@user), status: :created
        else
          head :unprocessable_entity
        end
      end

      def can_donate
        @integration = Integration.find_by_id_or_unique_address params[:integration_id]
        @platform = params[:user_agent]

        if current_user
          render json: { can_donate: current_user.can_donate?(@integration, @platform) }
        else
          render json: { can_donate: true }
        end
      end

      def completed_tasks
        if current_user
          render json: UserCompletedTaskBlueprint.render(current_user.user_completed_tasks)
        else
          render json: [], status: :not_found
        end
      end

      def complete_task
        if current_user
          task = ::Users::UpsertTask.call(user: current_user, task_identifier: params[:task_identifier]).result
          render json: UserCompletedTaskBlueprint.render(task)
        else
          head :unauthorized
        end
      end

      private

      def user_params
        params.permit(:email, :language, :user_agent)
      end
    end
  end
end
