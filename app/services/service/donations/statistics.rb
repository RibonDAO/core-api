module Service
  module Donations
    class Statistics
      attr_reader :donations

      MAXIMUM_INTERVALS = 5

      def initialize(donations:)
        @donations = donations
      end

      def total_donations
        @total_donations ||= donations.count
      end

      def total_donors
        @total_donors ||= donations.distinct.count(:user_id)
      end

      def donations_splitted_into_intervals
        (start_date.to_i..end_date.to_i).step(days_spacing).map do |date|
          range_start_date, range_end_date = chart_date_sub_range(date)

          {
            initial_date: range_start_date.strftime('%d/%m/%Y'),
            count: donations.created_between(range_start_date, range_end_date).count
          }
        end
      end

      def donors_splitted_into_intervals
        (start_date.to_i..end_date.to_i).step(days_spacing).map do |date|
          range_start_date, range_end_date = chart_date_sub_range(date)

          {
            initial_date: range_start_date.strftime('%d/%m/%Y'),
            count: donations.created_between(range_start_date, range_end_date).distinct.count(:user_id)
          }
        end
      end

      def total_new_donors
        users_ids = donations.pluck(:user_id).uniq
        User.where(id: users_ids).created_between(start_date, end_date).count
      end

      def total_donors_recurrent
        total_donors - total_new_donors
      end

      def impact_per_non_profit
        non_profits.map { |non_profit| format_impacts(non_profit) }
                   .select { |result| (result[:impact]).positive? }
      end

      def donations_per_non_profit
        non_profits.map { |non_profit| format_donations(non_profit) }
                   .select { |result| (result[:donations]).positive? }
      end

      def donors_per_non_profit
        non_profits.map { |non_profit| format_donors(non_profit) }
                   .select { |result| (result[:donors]).positive? }
      end

      def donations_splitted_into_intervals
        date_ranges_splitted.map do |date_range|
          {
            initial_date: date_range[:start_date].strftime('%d/%m/%Y'),
            count: donations.created_between(date_range[:start_date], date_range[:end_date]).count
          }
        end
      end

      def donors_splitted_into_intervals
        date_ranges_splitted.map do |date_range|
          {
            initial_date: date_range[:start_date].strftime('%d/%m/%Y'),
            count: donations.created_between(date_range[:start_date],
                                             date_range[:end_date]).distinct.count(:user_id)
          }
        end
      end

      private

      def days_spacing
        @spacing ||= (end_date - start_date) / GROUP_INTERVALS
        @spacing < 1.day ? 1.day : @spacing
      end

      def chart_date_sub_range(initial_timestamp)
        range_start_date = Time.zone.at(initial_timestamp)
        range_end_date   = Time.zone.at(initial_timestamp + days_spacing)

        [
          range_start_date,
          range_end_date > Time.zone.now ? Time.zone.now : range_end_date
        ]
      end

      def format_impacts(non_profit)
        impact =  impact_sum_by_non_profit(non_profit)
        { non_profit:, impact:, formatted_impact: formatted_impact(non_profit, impact) }
      end

      def format_donations(non_profit)
        { non_profit:, donations: donations.where(non_profit:).count }
      end

      def format_donors(non_profit)
        { non_profit:, donors: donations.where(non_profit:).distinct.count(:user_id) }
      end

      def impact_sum_by_non_profit(non_profit)
        usd_to_impact_factor = non_profit.impact_for&.usd_cents_to_one_impact_unit
        return 0 unless usd_to_impact_factor

        (total_usd_cents_donated_for(non_profit) / usd_to_impact_factor).to_i
      end

      def formatted_impact(non_profit, rounded_impact)
        ::Impact::Normalizer.new(non_profit, rounded_impact).normalize
      rescue Exceptions::ImpactNormalizationError
        ['', '', '']
      end

      def total_usd_cents_donated_for(non_profit)
        donations.where(non_profit:).sum(&:value)
      end

      def start_date
        @start_date ||= donations.order(:created_at).first&.created_at
      end

      def end_date
        @end_date ||= donations.order(:created_at).last&.created_at
      end

      def date_ranges_splitted
        @date_ranges_splitted = DateRange::Splitter.new(start_date, end_date, MAXIMUM_INTERVALS).split
      end

      def non_profits
        NonProfit.all
      end
    end
  end
end
