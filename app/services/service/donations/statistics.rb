module Service
  module Donations
    class Statistics
      attr_reader :donations

      GROUP_INTERVALS = 5

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
        slice_size = (donations.count / GROUP_INTERVALS).zero? ? 1 : donations.count / GROUP_INTERVALS

        donations.each_slice(slice_size).map do |donations_slice|
          {
            initial_date: donations_slice.first.created_at.strftime('%d/%m/%Y'),
            count: donations_slice.count
          }
        end
      end

      def donors_splitted_into_intervals
        slice_size = (donations.count / GROUP_INTERVALS).zero? ? 1 : donations.count / GROUP_INTERVALS

        donations.each_slice(slice_size).map do |donations_slice|
          {
            initial_date: donations_slice.first.created_at.strftime('%d/%m/%Y'),
            count: donations_slice.map(&:user_id).uniq.count
          }
        end
      end

      def total_new_donors
        start_date = donations.minimum(:created_at)
        end_date = donations.maximum(:created_at)
        users_ids = donations.pluck(:user_id).uniq
        users.where(id: users_ids).created_between(start_date, end_date).count
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

      private

      def format_impacts(non_profit)
        { non_profit:, impact: impact_sum_by_non_profit(non_profit) }
      end

      def format_donations(non_profit)
        { non_profit:, donations: donations.where(non_profit:).count }
      end

      def format_donors(non_profit)
        { non_profit:, donors: donations.where(non_profit:).distinct.count(:user_id) }
      end

      def impact_sum_by_non_profit(non_profit)
        usd_to_impact_factor = non_profit.impact_for.usd_cents_to_one_impact_unit

        (total_usd_cents_donated_for(non_profit) / usd_to_impact_factor).to_i
      end

      def total_usd_cents_donated_for(non_profit)
        donations.where(non_profit:).sum(&:value)
      end

      def non_profits
        NonProfit.all
      end

      def users
        User.all
      end
    end
  end
end
