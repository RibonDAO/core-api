module DateRange
  class Splitter
    attr_reader :start_date, :end_date, :intervals

    def initialize(start_date, end_date, intervals)
      @start_date = start_date
      @end_date   = end_date
      @intervals  = intervals
    end

    def split
      return [] if intervals.zero?

      (0...normalized_intervals).map do |i|
        {
          start_date: start_date + (i * interval_length),
          end_date: start_date + ((i + 1) * interval_length) - 1.second
        }
      end
    end

    private

    def interval_length
      @interval_length ||= (end_date - start_date + 1.second) / normalized_intervals
    end

    def days_difference
      @days_difference ||= (end_date - start_date).to_i / 1.day
    end

    def normalized_intervals
      return days_difference if intervals > days_difference

      intervals
    end
  end
end
