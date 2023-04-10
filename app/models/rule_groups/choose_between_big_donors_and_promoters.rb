class ChooseBetweenBigDonorsAndPromoters < RuleGroup
  PRIORITY = 1
  attr_reader :chosen_contributions

  def call(input = {})
    @chosen_contributions = input[:chosen]

    return big_donors_response if contributions_from_promoters.empty?
    return promoters_response  if contributions_from_big_donors.empty?

    case Random.rand
    when 0..limited_promoters_percent
      promoters_response
    when limited_promoters_percent..1
      big_donors_response
    end
  end

  private

  def contributions_from_big_donors
    chosen_contributions.from_big_donors
  end

  def contributions_from_promoters
    chosen_contributions.from_unique_donors
  end

  def big_donors_response
    {
      chosen: contributions_from_big_donors,
      found: false
    }
  end

  def promoters_response
    {
      chosen: contributions_from_promoters,
      found: false
    }
  end

  def promoters_percent
    percent = promoters_total_payments / (big_donors_total_payments + promoters_total_payments).to_f

    percent.nan? ? 0 : percent
  end

  def limited_promoters_percent
    0.5
  end

  def big_donors_percent
    1 - limited_promoters_percent
  end
end
