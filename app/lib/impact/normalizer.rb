module Impact
  class Normalizer
    MAX_AMOUNT_PER_DONOR_RECIPIENT = 200
    MAX_DAYS_PER_DONOR_RECIPIENT = 730

    attr_reader :non_profit_impact, :measurement_unit, :donor_recipient, :impact_description, :rounded_impact

    def initialize(non_profit, rounded_impact)
      @non_profit_impact   = non_profit.non_profit_impacts.last
      @measurement_unit    = @non_profit_impact&.measurement_unit
      @donor_recipient     = @non_profit_impact&.donor_recipient
      @impact_description  = @non_profit_impact&.impact_description
      @rounded_impact      = rounded_impact
    end

    def normalize
      if rounded_impact.nil? || rounded_impact.zero?
        raise Exceptions::ImpactNormalizationError, 'Impact cannot be zero'
      end

      [
        formatted_impact_amount,
        formatted_impact_description,
        formatted_donor_recipient
      ]
    end

    private

    def formatted_impact_amount
      raw_amount = rounded_impact / recipients_count

      based_on_time? ? period_in_words(raw_amount) : raw_amount.to_i.to_s
    end

    def formatted_impact_description
      impact = impact_description.split(',').map(&:strip).then do |descriptions|
        rounded_impact == 1 ? descriptions.first : descriptions.last
      end

      prefix = based_on_time? ? "#{I18n.t('impact_normalizer.of')} " : ''
      suffix = I18n.t('impact_normalizer.for')

      "#{prefix}#{impact} #{suffix}"
    end

    def formatted_donor_recipient
      suffix = donor_recipient.split(',').map(&:strip).then do |descriptions|
        recipients_count == 1 ? descriptions.first : descriptions.last
      end

      "#{recipients_count} #{suffix}"
    end

    def split_days_into_periods(days)
      years = days / 365
      days %= 365
      months = days / 30
      days %= 30
      [years, months, days]
    end

    def period_in_words(total_days)
      periods = split_days_into_periods(total_days)
      result = build_period_descriptions(periods)
      return '' if result.empty?

      format_period_descriptions(result)
    end

    def build_period_descriptions(periods)
      period_names = %w[year month day]

      periods.filter_map do |period|
        count = period_names.shift
        next if period.zero?

        "#{period} #{pluralize_period(count, period)}"
      end
    end

    def pluralize_period(period_name, period_amount)
      I18n.t("impact_normalizer.#{period_amount == 1 ? period_name : "#{period_name}s"}")
    end

    def format_period_descriptions(descriptions)
      return descriptions[0] if descriptions.length == 1

      "#{descriptions[0..-2].join(', ')} #{I18n.t('impact_normalizer.and')} #{descriptions[-1]}"
    end

    def based_on_time?
      measurement_unit == 'days_months_and_years'
    end

    def recipients_count
      divisor = based_on_time? ? MAX_DAYS_PER_DONOR_RECIPIENT : MAX_AMOUNT_PER_DONOR_RECIPIENT

      @recipients_count ||= (rounded_impact.to_f / divisor).ceil
    end
  end
end
