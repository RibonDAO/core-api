class DonationObserver < ActiveRecord::Observer
  def after_create(donation)
    Donations::HandlePostDonationJob.perform_later(donation:)
  rescue StandardError
    nil
  end
end
