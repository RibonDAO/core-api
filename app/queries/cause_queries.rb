class CauseQueries
  def active_with_pool_balance
    sql = %(
      SELECT causes.* FROM causes
      LEFT JOIN pools on pools.cause_id = causes.id
      LEFT JOIN pool_balances on pool_balances.pool_id = pools.id
      LEFT JOIN tokens on tokens.id = pools.token_id
      WHERE (pool_balances.id is null OR (pool_balances.balance > 0 AND tokens.chain_id = #{chain_id})))

    Cause.find_by_sql(sql)
  end

  private

  def chain_id
    Chain.default.id
  end
end
