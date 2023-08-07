module DonationServices
  class DonationBlockchainTransaction
    attr_reader :donation_blockchain_transaction

    def initialize(donation_blockchain_transaction:)
      @donation_blockchain_transaction = donation_blockchain_transaction
    end

    def update_status
      status = transaction_utils.transaction_status(donation_blockchain_transaction.transaction_hash)

      donation_blockchain_transaction.update!(status:)
    end

    private

    def transaction_utils
      @transaction_utils ||= Web3::Utils::TransactionUtils.new(chain:)
    end

    def chain
      @chain ||= donation_blockchain_transaction.chain
    end
  end
end
