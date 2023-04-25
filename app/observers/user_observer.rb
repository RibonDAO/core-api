class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Users::HandlePostUserJob.perform_later(user:)
  rescue StandardError
    nil
  end
end
