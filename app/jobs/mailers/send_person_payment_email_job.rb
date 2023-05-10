module Mailers
  class SendPersonPaymentEmailJob < ApplicationJob
    include ActionView::Helpers::NumberHelper
    queue_as :mailers
    sidekiq_options retry: 3

    attr_reader :user, :non_profit, :cause, :offer

    def perform(person_payment:)
      @person_payment = person_payment
      if person_payment.receiver_type == 'NonProfit'
        @non_profit = person_payment.receiver
      else
        @cause = person_payment.receiver
      end
      @offer = person_payment.offer
      @user = person_payment.payer&.user
      send_email
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end

    private

    def donation_receiver
      return 'non_profit' if non_profit

      'cause'
    end

    def receiver_name
      return non_profit.name if non_profit

      user.language == 'en' ? cause&.name_en : cause&.name_pt_br
    end

    def rounded_impact
      Service::Givings::Impact::NonProfitImpactCalculator.new(value: (offer.price_cents / 100), non_profit:,
                                                              currency: offer.currency).rounded_impact
    end

    def normalized_impact
      if non_profit
        ::Impact::Normalizer.new(
          non_profit,
          rounded_impact
        ).normalize.join(' ')
      else
        cause_value = offer.price_cents * 0.2
        donated_value(cause_value)
      end
    end

    def donated_value(value = offer.price_cents)
      if offer.currency == 'brl'
        number_to_currency((value / 100), unit: 'R$ ', separator: ',', delimiter: '.')
      else
        number_to_currency((value / 100), unit: '$ ', separator: '.', delimiter: ',')
      end
    end

    def send_email
      SendgridWebMailer.send_email(
        receiver: user.email,
        dynamic_template_data: {
          direct_giving_value: donated_value,
          receiver_name:,
          direct_giving_impact: normalized_impact
        },
        template_name: "giving_success_#{donation_receiver}_template_id",
        language: user.language
      ).deliver_later
    end
  end
end
