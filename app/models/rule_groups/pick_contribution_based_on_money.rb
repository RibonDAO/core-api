class PickContributionBasedOnMoney < RuleGroup
  PRIORITY = 4

  def call(input = {})
    contributions_group = input[:chosen]

    chosen = chosen_contribution(contributions_group)

    {
      chosen:,
      found: true
    }
  end

  private

  def chosen_contribution(contributions_group)
    probabilities = calculate_contributions_probability_based_on_money(contributions_group)
    contribution_id = select_contribution_id(probabilities)

    contributions_group.find { |contribution| contribution.id == contribution_id }
  end

  def calculate_contributions_probability_based_on_money(contributions_group)
    total_contributions_balance_sum = contributions_group.sum(&:usd_value_cents)

    probabilities_hash = {}
    contributions_group.each do |contribution|
      probabilities_hash[contribution.id] = contribution.usd_value_cents.to_f / total_contributions_balance_sum
    end

    probabilities_hash
  end

  def select_contribution_id(probabilities)
    # Generates a random number between 0 and 1
    random_number = Random.rand

    # Iterates through the hash of probabilities
    cumulative_probability = 0
    probabilities.each do |contribution_id, probability|
      # Convert probability to float
      probability = probability.to_f

      # Add the probability to the cumulative probability
      cumulative_probability += probability

      # If the cumulative probability is greater than the random number,
      # return the corresponding user ID
      return contribution_id if cumulative_probability > random_number
    end

    # If no user has been selected, return nil
    nil
  end
end
