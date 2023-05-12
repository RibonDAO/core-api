module Contributions
  class LabelMissedDonationsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :contributions

    def perform(*_args)
      Donation.without_label.find_each do |donation|
        Service::Contributions::TicketLabelingService.new(donation:).label_donation
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
