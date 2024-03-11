class SubscriptionObserver < ActiveRecord::Observer
  def after_update(subscription)
    if inactive_to_active?(person_payment)
      Events::Subscription::SendActivatedSubscriptionEventJob.perform_later(subscription:)
    end
    if active_to_canceled?(person_payment)
      Events::Subscription::SendCanceledSubscriptionEventJob.perform_later(subscription:)
    end
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
