module Donations
  class SendDonationBatchWorker
    include Sidekiq::Worker
    sidekiq_options queue: :batches

    # rubocop:disable Metrics/AbcSize
    def perform(*_args)
      Integration.all.each do |integration|
        NonProfit.all.each do |non_profit|
          [Time.zone.today.at_beginning_of_month, 1.month.ago.to_date.at_beginning_of_month].each do |period|
            batch = Donations::CreateDonationsBatch.call(integration:, non_profit:, period:).result
            Donations::CreateBatchBlockchainDonationJob.perform_later(non_profit:, integration:, batch:) if batch
          end
        end
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
    # rubocop:enable Metrics/AbcSize
  end
end
