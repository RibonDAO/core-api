class ContributionObserver < ActiveRecord::Observer
  def after_create(contribution)
    payer = contribution.person_payment.payer
    return unless payer.is_a?(Customer)

    Events::Contributions::SendContributionEventJob.perform_later(contribution:)
  rescue StandardError
    nil
  end
end
