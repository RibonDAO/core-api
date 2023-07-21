module Donations
  class BlockchainTransaction
    attr_reader :blockchain_transaction

    def initialize(blockchain_transaction:)
      @blockchain_transaction = blockchain_transaction
    end

    def update_status
      status = transaction_utils.transaction_status(blockchain_transaction.transaction_hash)

      blockchain_transaction.update!(status:)
    end

    private

    def transaction_utils
      @transaction_utils ||= Web3::Utils::TransactionUtils.new(chain:)
    end

    def chain
      @chain ||= blockchain_transaction.chain
    end
  end
end
