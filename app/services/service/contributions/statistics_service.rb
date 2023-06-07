module Service
  module Contributions
    class StatisticsService
      attr_reader :contribution

      def initialize(contribution:)
        @contribution = contribution
      end

      def formatted_statistics
        {
          initial_amount: format_money(initial_amount),
          used_amount: format_money(used_amount),
          remaining_amount: format_money(remaining_amount),
          total_tickets:,
          avg_donations_per_person:,
          boost_amount: format_money(boost_amount),
          total_increase_percentage:,
          total_amount_to_cause: format_money(total_amount_to_cause),
          ribon_fee: format_money(ribon_fee)
        }
      end

      def initial_amount
        return 0 if payment&.usd_value_cents.nil?

        payment.usd_value_cents / 100.0
      end

      def used_amount
        initial_amount - remaining_amount
      end

      def remaining_amount
        return 0 if balance&.remaining_total_cents.nil?

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
        return 0 if balance&.contribution_increased_amount_cents.nil?

        balance.contribution_increased_amount_cents / 100.0
      end

      def total_increase_percentage
        (boost_amount / initial_amount) * 100.0
      end

      def total_amount_to_cause
        initial_amount + boost_amount - ribon_fee
      end

      def ribon_fee
        paid_fees / 100.0
      end

      private

      def payment
        @payment ||= @contribution.person_payment
      end

      def balance
        @balance ||= @contribution.contribution_balance
      end

      def paid_fees
        @paid_fees ||= ContributionFee.where(payer_contribution: @contribution).sum(:fee_cents)
      end

      def format_money(amount)
        Money.from_amount(amount, :usd).format
      end
    end
  end
end