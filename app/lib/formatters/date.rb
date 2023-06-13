module Formatters
  class Date
    def self.in_words_for(start_time)
      difference_in_minutes = ((Time.zone.now - start_time) / 60).round

      format_by(difference_in_minutes)
    end

    def self.format_by(difference)
      case difference
      when 0
        I18n.t('date.time_units.half_minute')
      when 1..59
        pluralize(difference, 'minute')
      when 60..1439
        pluralize((difference / 60), 'hour')
      when 1440..10_079
        pluralize((difference / 1440), 'day')
      else
        pluralize((difference / 10_080), 'week')
      end
    end

    def self.pluralize(count, singular)
      key = count == 1 ? singular : singular.pluralize

      I18n.t("date.time_units.#{key}", count:).to_s
    end
  end
end
