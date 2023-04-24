module PersonPaymentServices
  class BlockchainTransaction
    attr_reader :person_blockchain_transaction

    def initialize(person_blockchain_transaction:)
      @person_blockchain_transaction = person_blockchain_transaction
    end

    def update_status
      status = transaction_utils.transaction_status(person_blockchain_transaction.transaction_hash)

      person_blockchain_transaction.update!(treasure_entry_status: status)
      update_person_payment_status(status)
    end

    private

    def transaction_utils
      @transaction_utils ||= Web3::Utils::TransactionUtils.new(chain:)
    end

    def chain
      @chain ||= Chain.default
    end

    def update_person_payment_status(status)
      person_payment = person_blockchain_transaction.person_payment
      if status == :success
        person_payment.update!(status: :paid)
      else
        person_payment.update!(status:)
      end
    end
  end
end
