module Contributions
  class LabelWorker
    include Sidekiq::Worker
    sidekiq_options queue: :relabel

    def perform
      ::Labeling::RelabelService.new(from: DonationContribution.last.created_at).relabel
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
