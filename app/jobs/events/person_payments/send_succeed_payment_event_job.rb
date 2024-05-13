module Events
  module PersonPayments
    class SendSucceedPaymentEventJob < ApplicationJob
      include ActionView::Helpers::NumberHelper
      queue_as :default
      sidekiq_options retry: 3

      attr_reader :user, :offer, :non_profit

      def perform(person_payment:)
        return if person_payment.receiver_type == 'Cause'

        @offer = person_payment.offer
        @user = person_payment.payer&.user
        @non_profit = person_payment.receiver
        EventServices::SendEvent.new(user:,
                                     event: build_event(person_payment)).call
      end

      private

      def build_event(person_payment)
        OpenStruct.new({
                         name: 'succeed_payment',
                         data: {
                           amount: donated_value,
                           receiver_name: person_payment.receiver.name,
                           impact: normalized_impact
                         }
                       })
      end

      def rounded_impact
        Service::Givings::Impact::NonProfitImpactCalculator.new(value: (offer.price_cents / 100), non_profit:,
                                                                currency: offer.currency).rounded_impact
      end

      def normalized_impact
        ::Impact::Normalizer.new(
          non_profit,
          rounded_impact
        ).normalize.join(' ')
      end

      def donated_value(value = offer.price_cents)
        if offer.currency == 'brl'
          number_to_currency((value / 100), unit: 'R$ ', separator: ',', delimiter: '.')
        else
          number_to_currency((value / 100), unit: '$ ', separator: '.', delimiter: ',')
        end
      end
    end
  end
end
