module Contributions
  class LabelUnlabelledRecordsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :label_unlabelled_records

    def perform
      ::Labeling::RelabelService.new.label_unlabelled_records
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
