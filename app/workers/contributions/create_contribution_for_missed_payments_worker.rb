module Contributions
  class CreateContributionForMissedPaymentsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :contributions

    def perform(*_args)
      PersonPayment.paid.without_contribution.each do |payment|
        Contributions::CreateContribution.call(payment:)
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
