class SubscriptionObserver < ActiveRecord::Observer
  def after_update(subscription)
    Events::Club::SendActivatedClubEventJob.perform_later(subscription:) if inactive_to_active?(subscription)
    Events::Club::SendCanceledClubEventJob.perform_later(subscription:) if active_to_canceled?(subscription)
  rescue StandardError
    nil
  end

  def inactive_to_active?(subscription)
    subscription.previous_changes[:status] == %w[inactive active]
  end

  def actove_to_canceled?(subscription)
    subscription.previous_changes[:status] == %w[active canceled]
  end
end
