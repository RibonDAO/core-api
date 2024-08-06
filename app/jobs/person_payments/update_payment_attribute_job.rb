module PersonPayments
  class UpdatePaymentAttributeJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 3

    def perform(person_payment, attributes)
      person_payment&.update(attributes)
    end
  end
end
