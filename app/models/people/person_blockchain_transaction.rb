# == Schema Information
#
# Table name: person_blockchain_transactions
#
#  id                    :bigint           not null, primary key
#  succeeded_at          :datetime
#  transaction_hash      :string
#  treasure_entry_status :integer          default("processing")
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  person_payment_id     :bigint
#
class PersonBlockchainTransaction < ApplicationRecord
  belongs_to :person_payment

  after_create :update_status_from_eth_chain
  after_update :handle_blockchain_success, if: proc { |obj|
    obj.saved_change_to_treasure_entry_status? && obj.success?
  }

  enum treasure_entry_status: {
    processing: 0,
    success: 1,
    failed: 2,
    dropped: 3,
    replaced: 4
  }

  def update_status_from_eth_chain
    # TODO: add listener to contract events to call this method
    PersonPayments::UpdateBlockchainTransactionStatusJob
      .set(wait_until: 5.minutes.from_now)
      .perform_later(self)
  end

  def handle_blockchain_success
    increase_pool_balance
    set_succeeded_at
    charge_contribution_fees
  end

  def increase_pool_balance
    return unless person_payment.receiver_type == 'Cause'

    pool = person_payment.receiver.default_pool
    Service::Donations::PoolBalances.new(pool:).increase_balance(person_payment.crypto_amount)
  end

  def charge_contribution_fees
    return unless saved_change_to_treasure_entry_status? && success?
    return if person_payment&.contribution&.generated_fee_cents&.zero?

    Service::Contributions::FeesLabelingService.new(contribution: person_payment.contribution).spread_fee_to_payers
  end

  def set_succeeded_at
    return if succeeded_at.present?

    update(succeeded_at: Time.current)
  end

  def retry?
    %w[failed dropped replaced].include?(treasure_entry_status)
  end
end
