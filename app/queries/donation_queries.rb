# frozen_string_literal: true

class DonationQueries
  attr_reader :cause

  def initialize(cause:)
    @cause = cause
  end

  def amount_free_donations
    sql = %(
      SELECT SUM(value) as sum FROM donations
      LEFT JOIN non_profits ON non_profits.id = donations.non_profit_id
      LEFT JOIN causes ON causes.id = non_profits.cause_id
      WHERE causes.id = #{cause.id})

    ActiveRecord::Base.connection.execute(sql).first['sum'] || 0
  end

  def amount_free_donations_without_batch
    sql = %(
      SELECT SUM(value) as sum FROM donations
      LEFT JOIN non_profits ON non_profits.id = donations.non_profit_id
      LEFT JOIN causes ON causes.id = non_profits.cause_id
      LEFT JOIN donation_batches ON donation_batches.donation_id = donations.id
      LEFT JOIN blockchain_transactions ON blockchain_transactions.owner_id = donation_batches.batch_id AND blockchain_transactions.owner_type = 'Batch'
      LEFT JOIN donation_blockchain_transactions on donation_blockchain_transactions.donation_id = donations.id
      WHERE causes.id = #{cause.id}
      AND (donation_batches.id is null or blockchain_transactions.status = 0)
      AND donation_blockchain_transactions.id is null)

    ActiveRecord::Base.connection.execute(sql).first['sum'] || 0
  end
end
