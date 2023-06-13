# frozen_string_literal: true

class ContributionQueries
  attr_reader :contribution

  def initialize(contribution:)
    @contribution = contribution
  end

  def ordered_feeable_contribution_balances
    ContributionBalance
      .with_fees_balance
      .with_paid_status
      .where.not(contribution_id: contribution.id)
      .joins(:contribution).where(contributions: { receiver: contribution.receiver })
      .order(fees_balance_cents: :asc)
  end

  def ordered_feeable_tickets_contribution_balances
    ContributionBalance
      .with_tickets_balance
      .with_paid_status
      .where.not(contribution_id: contribution.id)
      .order(tickets_balance_cents: :asc)
  end
end
