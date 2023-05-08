module UserServices
  class UserStreakTasks
    attr_reader :user

    def initialize(user:)
      @user = user
      @statistics = UserTasksStatistic.find_by(user:)
    end

    def should_reset_streak?
      today = Time.zone.today
      yesterday = today - 1.day
      last_completed_task_date = user.user_completed_tasks.order(last_completed_at: :desc).first&.last_completed_at

      return true if last_completed_task_date.nil?
      return true if last_completed_task_date < yesterday

      false
    end

    def should_increment_streak?
      return false if user.user_completed_tasks.blank?

      completed_tasks_today = user.user_completed_tasks.where(last_completed_at: Time.zone.now.all_day).count
      return false if completed_tasks_today != 1

      true
    end

    def reset_streak
      @statistics.update(streak: 0)
    end

    def increment_streak
      @statistics.update(streak: @statistics.streak + 1) if should_increment_streak?
    end
  end
end
