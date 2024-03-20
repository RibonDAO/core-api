module Users
  module V1
    module Tasks
      class StatisticsController < AuthorizationController
        def index
          tasks_statistics = if current_user.user_tasks_statistic.nil?
                               UserTasksStatistic.create!(user: current_user)
                             else
                               current_user.user_tasks_statistic
                             end

          render json: UserTasksStatisticsBlueprint.render(tasks_statistics)
        end

        def streak
          tasks_statistics = current_user.user_tasks_statistic

          render json: { streak: tasks_statistics.streak }
        end

        def completed_tasks
          render json: UserCompletedTaskBlueprint.render(current_user.user_completed_tasks)
        end
      end
    end
  end
end
