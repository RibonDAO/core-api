class ContributionObserver < ActiveRecord::Observer
  def after_create(contribution)
    payer = contribution.person_payment.payer
    return unless payer.is_a?(Customer)
    return if contribution&.person_payment&.subscription&.category == 'club'

    Events::Contributions::SendContributionEventJob.perform_later(contribution:)
  rescue StandardError
    nil
  end
end
