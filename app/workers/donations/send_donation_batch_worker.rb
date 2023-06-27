module Donations
  class SendDonationBatchWorker
    include Sidekiq::Worker
    sidekiq_options queue: :batches

    def perform(*_args)
      Integration.all.each do |integration|
        NonProfit.all.each do |non_profit|
          Helper.sleep(30)
          batch = Donations::CreateDonationsBatch.call(integration:, non_profit:).result
          Donations::CreateBatchBlockchainDonationJob.perform_later(non_profit:, integration:, batch:) if batch
        end
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
