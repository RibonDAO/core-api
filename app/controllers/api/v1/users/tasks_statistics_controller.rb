module Api
  module V1
    module Users
      class TasksStatisticsController < ApplicationController
        def update_streak
          return unless current_user

          service = ::UserServices::UserTasksStreak.new(user: current_user)

          service.reset_streak if service.should_reset_streak?
        end

        def index
          return unless current_user

          tasks_statistics = if current_user.user_tasks_statistic.nil?
                               UserTasksStatistic.create!(user: current_user)
                             else
                               current_user.user_tasks_statistic
                             end

          render json: UserTasksStatisticsBlueprint.render(tasks_statistics)
        end

        def streak
          return unless current_user

          tasks_statistics = current_user.user_tasks_statistic

          render json: { streak: tasks_statistics.streak }
        end

        def first_completed_all_tasks_at
          return unless current_user

          tasks_statistic = current_user.user_tasks_statistic

          if tasks_statistic.nil?

            UserTasksStatistic.create!(user: current_user,
                                       first_completed_all_tasks_at: Time.zone.now)
          else
            tasks_statistic.update(first_completed_all_tasks_at: Time.zone.now)
          end

          render json: UserTasksStatisticsBlueprint.render(tasks_statistic)
        end
      end
    end
  end
end
