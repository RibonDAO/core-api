module Contributions
  class RelabelWorker
    include Sidekiq::Worker
    sidekiq_options queue: :relabel

    def perform
      ::Labeling::RelabelService.new(from: 3.years.ago).relabel
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
