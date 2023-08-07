module DonationServices
  class PoolBalances
    attr_reader :pool

    def initialize(pool:)
      @pool = pool
    end

    def add_balance_history
      balance = wallet_pool_balance
      pool.balance_histories.create!(cause:, balance:, amount_donated:) if balance.positive?
    end

    def update_balance
      balance = wallet_pool_balance -
                amount_free_donations_without_batch -
                amount_free_donations_with_batch_processing -
                amount_free_donations_with_batch_failed
      pool_balance.update!(balance:)
    end

    def decrease_balance(value)
      return if pool.pool_balance.nil?

      balance = pool_balance.balance - value
      pool_balance.update!(balance:)
    end

    def increase_balance(value)
      return if pool.pool_balance.nil?

      balance = pool_balance.balance + value
      pool_balance.update!(balance:)
    end

    private

    def cause
      pool.cause
    end

    def contract_address
      pool.token.address
    end

    def address
      pool.address
    end

    def pool_balance
      pool.pool_balance || PoolBalance.create!(pool:, balance: 0)
    end

    def wallet_pool_balance
      Web3::Networks::Polygon::Scan.new(contract_address:, address:).balance.to_f / (10**pool.token.decimals)
    end

    def amount_free_donations
      DonationQueries.new(cause:).amount_free_donations.to_f / 100
    end

    def amount_free_donations_without_batch
      DonationQueries.new(cause:).amount_free_donations_without_batch.to_f / 100
    end

    def amount_free_donations_with_batch_processing
      DonationQueries.new(cause:).amount_free_donations_with_batch_processing.to_f / 100
    end

    def amount_free_donations_with_batch_failed
      DonationQueries.new(cause:).amount_free_donations_with_batch_failed.to_f / 100
    end

    def amount_donated
      amount_free_donations
    end
  end
end
