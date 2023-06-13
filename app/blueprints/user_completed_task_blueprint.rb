class UserCompletedTaskBlueprint < Blueprinter::Base
  identifier :id

  fields :last_completed_at, :task_identifier, :times_completed

  field(:done) do |user_completed_task|
    user_completed_task.done?
  end

  field(:expires_at) do |user_completed_task|
    user_completed_task.expires_at
  end
end
