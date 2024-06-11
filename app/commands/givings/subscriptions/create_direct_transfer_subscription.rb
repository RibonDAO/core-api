module Givings
  module Subscriptions
    class CreateDirectTransferSubscription
      prepend SimpleCommand

      attr_reader :email, :offer, :user, :payment_method, :integration_id

      def initialize(args)
        @payment_method = :direct_transfer
        @email = args[:email]
        @offer = args[:offer]
        @integration_id = args[:integration_id]
      end

      def call
        return unless offer&.plan

        @user = find_or_create_user
        customer = find_or_create_customer
        return if subscription_already_exists(customer)

        subscription = create_subscription(customer)
        give_monthly_tickets(subscription)
        give_daily_tickets(subscription)
      rescue StandardError => e
        Reporter.log(error: e, extra: { message: e.message }, level: :fatal)
        errors.add(:message, e.message)
      end

      def find_or_create_user
        user = User.find_by(email:)
        return user if user

        User.create(email:, language: I18n.locale)
      end

      def find_or_create_customer
        customer = Customer.find_by(user_id: user.id)
        return customer if customer

        Customer.create!(email:, name: email.split('@').first, user:)
      end

      def create_subscription(payer)
        Subscription.create!({ payer:,
                               offer:,
                               payment_method:,
                               integration:,
                               next_payment_attempt:,
                               status: :active })
      end

      def integration
        Integration.find_by_id_or_unique_address(integration_id)
      end

      def next_payment_attempt
        1.month.from_now
      end

      def give_monthly_tickets(subscription)
        Tickets::GenerateClubMonthlyTicketsJob.perform_later(
          user: subscription.payer.user,
          platform: subscription.platform,
          quantity: subscription.offer.plan.monthly_tickets,
          source: :club
        )
      end

      def give_daily_tickets(subscription)
        Tickets::GenerateClubDailyTicketsJob.perform_later(
          user: subscription.payer.user,
          platform: subscription.platform,
          quantity: subscription.offer.plan.daily_tickets,
          source: :club
        )
      end

      def subscription_already_exists(payer)
        Subscription.exists?(payer:, status: :active)
      end
    end
  end
end
