class UserTasksStatisticsBlueprint < Blueprinter::Base
  fields :first_completed_all_tasks_at, :streak, :contributor
end
