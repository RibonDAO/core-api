module Events
  module Contributions
    class SendContributionEventJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3

      attr_reader :user, :non_profit, :cause, :offer, :person_payment

      def perform(contribution:)
        initialize_variables(contribution)
        build_event(contribution)

        EventServices::SendEvent.new(user: contribution.person_payment.payer.user,
                                     event: build_event(contribution)).call
      end

      def initialize_variables(contribution)
        @person_payment = contribution.person_payment
        if contribution.person_payment.receiver_type == 'NonProfit'
          @non_profit = contribution.person_payment.receiver
        else
          @cause = contribution.person_payment.receiver
        end
        @offer = contribution.person_payment.offer
        @user = contribution.person_payment.payer&.user
      end

      def rounded_impact
        Service::Givings::Impact::NonProfitImpactCalculator.new(value: (offer.price_cents / 100), non_profit:,
                                                                currency: offer.currency).rounded_impact
      end

      def non_profit_impact
        return unless non_profit

        ::Impact::Normalizer.new(
          non_profit,
          rounded_impact
        ).normalize.join(' ')
      end

      def cause_increased_amount
        return unless cause

        amount_cents = (offer.price_cents * 0.2) + offer.price_cents
        Money.from_cents(amount_cents, offer.currency).format
      end

      def build_event(contribution)
        if person_payment.subscription.present?
          subscribed_event(contribution)
        else
          contributed_event(contribution)
        end
      end

      def formatted_payment_day
        person_payment.paid_date.strftime('%d')
      end

      def new_subscription
        person_payment.subscription && PersonPayment
          .where(subscription: person_payment.subscription).count == 1
      end

      def contributed_event(contribution)
        OpenStruct.new({
                         name: 'contributed',
                         data: event_common_data(contribution)
                         .merge({
                                  paid_date: person_payment.paid_date
                                })
                       })
      end

      def subscribed_event(contribution)
        OpenStruct.new({
                         name: 'subscribed',
                         data: event_common_data(contribution)
                         .merge({
                                  payment_day: formatted_payment_day,
                                  new_subscription:,
                                  paid_date: person_payment.paid_date.strftime('%d/%m/%Y')
                                })
                       })
      end

      # rubocop:disable Metrics/AbcSize
      def event_common_data(contribution)
        {
          contribution_id: contribution.id,
          integration_id: person_payment.integration_id,
          receiver_type: person_payment.receiver_type,
          receiver_id: person_payment.receiver_id,
          currency: person_payment.currency,
          platform: person_payment.platform,
          amount: person_payment.formatted_amount,
          status: person_payment.status,
          offer_id: person_payment.offer_id,
          total_number_of_contributions: person_payment.payer.contributions.count,
          impact: non_profit_impact || cause_increased_amount,
          receiver_name: person_payment.receiver.name
        }
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
