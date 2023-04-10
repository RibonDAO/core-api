class ChooseContributionsCause < RuleGroup
  PRIORITY = 2
  attr_reader :chosen_contributions

  def call(input = {})
    @chosen_contributions = input[:chosen]

    {
      chosen: contributions_by_cause,
      found: false
    }
  end

  private

  def contributions_by_cause
    chosen_contributions.where(receiver: @donation.cause)
  end
end
