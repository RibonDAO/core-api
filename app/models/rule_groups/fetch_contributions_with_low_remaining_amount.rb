class FetchContributionsWithLowRemainingAmount < RuleGroup
  PRIORITY = 3
  attr_reader :chosen_contributions

  def call(input = {})
    @chosen_contributions = input[:chosen]

    return empty if chosen_contributions.empty?

    allowed_chosen_contributions = chosen_contributions.with_tickets_balance_less_than_10_percent

    return input if allowed_chosen_contributions.empty?

    {
      chosen: allowed_chosen_contributions.sample,
      found: true
    }
  end
end
