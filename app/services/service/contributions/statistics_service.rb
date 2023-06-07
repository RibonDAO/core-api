module Service
  module Contributions
    class StatisticsService
      attr_reader :contribution

      def initialize(contribution:)
        @contribution = contribution
      end

      def formatted_statistics
        { initial_amount:, used_amount:, remaining_amount:, total_tickets:, avg_donations_per_person:,
          boost_amount:, total_increase_percentage:, total_amount_to_cause:, ribon_fee: }
      end

      def initial_amount
        payment.usd_value_cents / 100.0
      end

      def used_amount
        initial_amount - remaining_amount
      end

      def remaining_amount
        balance.remaining_total_cents / 100.0
      end

      def total_tickets
        contribution.donations.count
      end

      def total_donors
        contribution.users.distinct.count
      end

      def avg_donations_per_person
        return 0 if total_donors.zero?

        total_tickets / total_donors
      end

      def boost_amount
        balance.contribution_increased_amount_cents / 100.0
      end

      def total_increase_percentage
        (boost_amount / initial_amount) * 100.0
      end

      def total_amount_to_cause
        initial_amount + boost_amount - ribon_fee
      end

      def ribon_fee
        contribution.contribution_fees.sum(:fee_cents) / 100.0
      end

      private

      def payment
        @payment ||= @contribution.person_payment
      end

      def balance
        @balance ||= @contribution.contribution_balance
      end
    end
  end
end
