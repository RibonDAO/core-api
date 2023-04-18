class NonProfitQueries
  def active_with_pool_balance
    sql = %(
      SELECT non_profits.* FROM non_profits
      LEFT JOIN causes on causes.id = non_profits.cause_id
      LEFT JOIN pools on pools.cause_id = causes.id
      LEFT JOIN pool_balances on pool_balances.pool_id = pools.id
      LEFT JOIN tokens on tokens.id = pools.token_id
      WHERE (pool_balances.id is null OR (pool_balances.balance > 0 AND tokens.chain_id = #{chain_id}))
      AND non_profits.status = 1
      ORDER BY non_profits.cause_id asc)

    NonProfit.find_by_sql(sql)
  end

  private

  def chain_id
    Chain.default.id
  end
end
