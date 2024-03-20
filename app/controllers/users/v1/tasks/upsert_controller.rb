module Users
  module V1
    module Tasks
      class UpsertController < AuthorizationController
        def reset_streak
          service = ::UserServices::UserTasksStreak.new(user: current_user)

          service.reset_streak if service.should_reset_streak?
        end

        def first_completed_all_tasks_at
          tasks_statistic = current_user.user_tasks_statistic

          if tasks_statistic.nil?

            UserTasksStatistic.create!(user: current_user,
                                       first_completed_all_tasks_at: Time.zone.now)
          else
            tasks_statistic.update(first_completed_all_tasks_at: Time.zone.now)
          end

          render json: UserTasksStatisticsBlueprint.render(tasks_statistic)
        end

        def complete_task
          task = ::Users::UpsertTask.call(user: current_user, task_identifier: params[:task_identifier]).result

          ::Users::IncrementStreak.call(user: current_user)
          render json: UserCompletedTaskBlueprint.render(task)
        end
      end
    end
  end
end
