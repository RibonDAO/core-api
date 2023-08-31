class BatchQueries
  attr_reader :non_profit, :integration, :period

  def initialize(non_profit:, integration:, period:)
    @non_profit = non_profit
    @integration = integration
    @period = period
  end

  def donations_without_batch
    sql = %(Select distinct(donations.id) from donations
            left outer join donation_blockchain_transactions dbt on dbt.donation_id = donations.id
            left outer join donation_batches dba on dba.donation_id = donations.id
            where dbt is null
            and dba is null
            and donations.integration_id = #{integration.id}
            and donations.non_profit_id = #{non_profit.id}
            and donations.created_at > '#{period.beginning_of_day}'
            and donations.created_at < '#{period.at_end_of_month.end_of_day}')
    ActiveRecord::Base.connection.execute(sql).map do |t|
      t['id']
    end
  end
end
