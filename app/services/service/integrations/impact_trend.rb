module Service
  module Integrations
    class ImpactTrend
      attr_reader :integration, :start_date, :end_date

      def initialize(integration:, start_date:, end_date:)
        @integration = integration
        @start_date = start_date
        @end_date = end_date
      end

      delegate :total_donations, :total_donors, :impact_per_non_profit, :donations_per_non_profit,
               :total_new_donors, :total_donors_recurrent,
               :donors_per_non_profit, to: :impact_service

      def formatted_impact
        {
          total_donations:,
          total_donors:,
          impact_per_non_profit:,
          donations_per_non_profit:,
          donors_per_non_profit:,
          previous_total_donations:, previous_total_donors:,
          previous_donations_per_non_profit:, previous_donors_per_non_profit:, previous_impact_per_non_profit:,
          total_donations_balance:, total_donors_balance:,
          total_donations_trend:, total_donors_trend:,
          total_new_donors:, total_donors_recurrent:
        }
      end

      def total_donations_trend
        return 0 if previous_total_donations.zero?

        total_donations_balance.percent_of(previous_total_donations).round(2)
      end

      def total_donors_trend
        return 0 if previous_total_donors.zero?

        total_donors_balance.percent_of(previous_total_donors).round(2)
      end

      def previous_total_donors
        previous_impact_service.total_donors
      end

      def previous_total_donations
        previous_impact_service.total_donations
      end

      def previous_impact_per_non_profit
        previous_impact_service.impact_per_non_profit
      end

      def previous_donations_per_non_profit
        previous_impact_service.donations_per_non_profit
      end

      def previous_donors_per_non_profit
        previous_impact_service.donors_per_non_profit
      end

      def total_donations_balance
        impact_service.total_donations - previous_total_donations
      end

      def total_donors_balance
        impact_service.total_donors - previous_total_donors
      end

      private

      def impact_service
        @impact_service ||= Impact.new(integration:, start_date:, end_date:)
      end

      def previous_impact_service
        @previous_impact_service ||= Impact.new(integration:, start_date: previous_start_date,
                                                end_date: previous_end_date)
      end

      def previous_start_date
        start_date - time_offset
      end

      def previous_end_date
        end_date - time_offset
      end

      def time_offset
        (start_date - end_date).abs
      end
    end
  end
end
