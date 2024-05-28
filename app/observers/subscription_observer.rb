class SubscriptionObserver < ActiveRecord::Observer
  def after_update(subscription)
    Events::Club::SendActivatedClubEventJob.perform_later(subscription:) if club_inactive_to_active?(subscription)
    Events::Club::SendCanceledClubEventJob.perform_later(subscription:) if club_active_to_canceled?(subscription)
    Events::Club::SendInactivatedClubEventJob.perform_later(subscription:) if club_revoked?(subscription)
  rescue StandardError
    nil
  end

  def club_inactive_to_active?(subscription)
    subscription.category == 'club' && subscription.previous_changes[:status] == %w[inactive active]
  end

  def club_active_to_canceled?(subscription)
    subscription.category == 'club' && subscription.previous_changes[:status] == %w[active canceled]
  end

  def club_revoked?(subscription)
    subscription.category == 'club' && subscription.payment_method == 'pix' &&
      subscription.previous_changes[:status] == %w[active inactive]
  end
end
