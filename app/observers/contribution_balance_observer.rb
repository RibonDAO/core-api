class ContributionBalanceObserver < ActiveRecord::Observer
  def after_update(contribution_balance)
    payer = contribution_balance.contribution.person_payment.payer
    return unless payer.is_a?(BigDonor)

    Contributions::HandleUpdateContributionBalanceJob.perform_later(contribution_balance:, big_donor: payer)
  rescue StandardError
    nil
  end
end
