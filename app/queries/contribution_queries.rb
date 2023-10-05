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
      .confirmed_on_blockchain_before(contribution.person_payment.person_blockchain_transaction.succeded_at)
      .where.not(contribution_id: contribution.id)
      .joins(:contribution).where(contributions: { receiver: contribution.receiver })
      .order(fees_balance_cents: :asc)
  end

  def ordered_feeable_tickets_contribution_balances
    ContributionBalance
      .with_tickets_balance
      .with_paid_status
      .confirmed_on_blockchain_before(contribution.person_payment.person_blockchain_transaction.succeded_at)
      .where.not(contribution_id: contribution.id)
      .joins(:contribution).where(contributions: { receiver: contribution.receiver })
      .order(tickets_balance_cents: :asc)
  end

  def boost_new_contributors
    sql = %(
      SELECT count(distinct person_payments.payer_id) FROM contributions
      LEFT JOIN person_payments on person_payments.id = contributions.person_payment_id
      WHERE contributions.id = ANY(
        select contribution_id from contribution_fees
        where payer_contribution_id = #{contribution.id}
      )
      AND person_payments.payer_type = 'Customer'
      AND person_payments.status = 1)

    ActiveRecord::Base.connection.execute(sql).first['count'] || 0
  end

  def boost_new_patrons
    sql = %(
      SELECT count(distinct person_payments.payer_id) FROM contributions
      LEFT JOIN person_payments on person_payments.id = contributions.person_payment_id
      WHERE contributions.id = ANY(
        select contribution_id from contribution_fees
        where payer_contribution_id = #{contribution.id}
      )
      AND person_payments.payer_type = 'BigDonor'
      AND person_payments.status = 1)

    ActiveRecord::Base.connection.execute(sql).first['count'] || 0
  end

  def top_donations_non_profit
    sql = %(
      SELECT donations.non_profit_id, sum(donations.value) as total_amount
      FROM contributions
      LEFT JOIN donation_contributions on donation_contributions.contribution_id = contributions.id
      LEFT JOIN donations on donations.id = donation_contributions.donation_id
      WHERE contributions.id = #{contribution.id}
      GROUP BY donations.non_profit_id
      ORDER BY total_amount DESC
      LIMIT 1)

    id = ActiveRecord::Base.connection.execute(sql).first['non_profit_id']
    NonProfit.find_by(id:)
  end
end
