class RuleGroup
  attr_reader :donation

  def initialize(donation)
    @donation = donation
  end

  def self.rules_set
    ObjectSpace.each_object(Class).select { |klass| klass < self }.sort_by { |klass| klass::PRIORITY }
  end

  def promoters_total_payments
    total_payments_from(contributions_from_promoters)
  end

  def big_donors_total_payments
    total_payments_from(contributions_from_big_donors)
  end

  def total_payments_from(contributions)
    tickets_contributions_balance = contributions.sum do |contribution|
      contribution.contribution_balance.tickets_balance_cents
    end
    fees_contributions_balance = contributions.sum do |contribution|
      contribution.contribution_balance.fees_balance_cents
    end
    return fees_contributions_balance if tickets_contributions_balance < donation.value

    tickets_contributions_balance
  end

  protected

  def empty
    {
      chosen: [],
      found: false
    }
  end
end
