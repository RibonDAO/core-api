module DateRange
  class Helper
    attr_reader :start_date, :end_date

    def initialize(start_date:, end_date:)
      @start_date = start_date
      @end_date   = end_date
    end

    def months_difference
      return 0 if start_date.nil? || end_date.nil?

      months_difference = (end_date - start_date).to_i / 1.month

      months_difference.abs
    end
  end
end
