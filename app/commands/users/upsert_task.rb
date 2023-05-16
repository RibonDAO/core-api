# frozen_string_literal: true

module Users
  class UpsertTask < ApplicationCommand
    prepend SimpleCommand

    attr_reader :user, :task_identifier

    def initialize(user:, task_identifier:)
      @user = user
      @task_identifier = task_identifier
    end

    def call
      with_exception_handle do
        return unless user

        task = user.user_completed_tasks.find_by(task_identifier:)

        if task
          task.update(last_completed_at:, times_completed: task.times_completed + 1) unless task.done?
        else
          task = user.user_completed_tasks.create(task_identifier:, last_completed_at:, times_completed: 1)
        end

        task
      end
    end

    private

    def last_completed_at
      Time.zone.now
    end
  end
end
