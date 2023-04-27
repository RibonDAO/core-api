# == Schema Information
#
# Table name: person_blockchain_transactions
#
#  id                    :bigint           not null, primary key
#  transaction_hash      :string
#  treasure_entry_status :integer          default("processing")
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  person_payment_id     :bigint
#
class PersonBlockchainTransaction < ApplicationRecord
  belongs_to :person_payment

  after_create :update_status_from_eth_chain
  after_update :increase_pool_balance, if: :success?

  enum treasure_entry_status: {
    processing: 0,
    success: 1,
    failed: 2
  }

  def update_status_from_eth_chain
    # TODO: add listener to contract events to call this method
    PersonPayments::UpdateBlockchainTransactionStatusJob
      .set(wait_until: 5.minutes.from_now)
      .perform_later(self)
  end

  def increase_pool_balance
    return unless person_payment.receiver_type == 'Cause'

    pool = person_payment.receiver.default_pool
    Service::Donations::PoolBalances.new(pool:).increase_balance(person_payment.crypto_amount)
  end
end
