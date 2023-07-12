module Service
  module Contributions
    class StatisticsService
      attr_reader :contribution

      def initialize(contribution:)
        @contribution = contribution
      end

      # rubocop:disable Metrics/AbcSize
      def formatted_statistics
        {
          initial_amount: payment.formatted_amount, used_amount: format_money(used_amount),
          usage_percentage:, remaining_amount: format_money(remaining_amount),
          total_tickets:, avg_donations_per_person:, boost_amount: format_money(boost_amount),
          total_increase_percentage:, total_amount_to_cause: format_money(total_amount_to_cause),
          ribon_fee: format_money(ribon_fee), boost_new_contributors:, boost_new_patrons:,
          total_donors:, total_contributors:
        }
      end

      def formatted_email_statistics
        {
          boost_amount:,
          boost_new_contributors:,
          boost_new_patrons:,
          constribution_receiver_name: contribution.receiver[:name],
          top_donations_non_profit_impact:,
          top_donations_non_profit_name:,
          total_donors:,
          total_increase_percentage:,
          usage_percentage:
        }
      end
      # rubocop:enable Metrics/AbcSize

      def initial_amount
        return 0 if payment&.usd_value_cents.nil?

        payment.usd_value_cents / 100.0
      end

      def used_amount
        initial_amount - remaining_amount
      end

      def usage_percentage
        ((used_amount.to_f / initial_amount).round(2) * 100).round(2)
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

      def top_donations_non_profit
        @top_donations_non_profit ||= ContributionQueries.new(contribution:).top_donations_non_profit
      end

      def top_donations_impact
        return unless top_donations_non_profit

        DirectImpactService.new(contribution:)
                           .direct_impact_for(top_donations_non_profit)[:formatted_impact]
      end

      def top_donations_non_profit_name
        top_donations_non_profit&.name
      end

      def top_donations_non_profit_impact
        top_donations_impact&.join(' ')
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
        ((boost_amount / initial_amount) * 100.0).round(2)
      end

      def total_amount_to_cause
        initial_amount + boost_amount - ribon_fee
      end

      def ribon_fee
        paid_fees / 100.0
      end

      def boost_new_contributors
        ContributionQueries.new(contribution:).boost_new_contributors
      end

      def boost_new_patrons
        ContributionQueries.new(contribution:).boost_new_patrons
      end

      def total_contributors
        boost_new_contributors + boost_new_patrons
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
        Currency::Converters.convert(from: :usd, to: payment.currency, value: amount).round.format
      end
    end
  end
end
