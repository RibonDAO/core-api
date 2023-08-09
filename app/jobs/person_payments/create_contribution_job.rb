module PersonPayments
  class CreateContributionJob < ApplicationJob
    queue_as :default

    def perform(payment)
      Contributions::CreateContribution.call(payment:)
    end
  end
end
