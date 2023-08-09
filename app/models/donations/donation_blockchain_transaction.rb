# == Schema Information
#
# Table name: donation_blockchain_transactions
#
#  id               :bigint           not null, primary key
#  status           :integer          default("processing")
#  transaction_hash :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  chain_id         :bigint           not null
#  donation_id      :bigint           not null
#
class DonationBlockchainTransaction < ApplicationRecord
  belongs_to :donation
  belongs_to :chain

  validates :transaction_hash, presence: true

  after_create :update_status_from_chain

  enum status: {
    processing: 0,
    success: 1,
    failed: 2
  }

  def transaction_link
    "#{chain.block_explorer_url}tx/#{transaction_hash}"
  end

  def update_status_from_chain
    # TODO: add listener to contract events to call this method
    Donations::UpdateDonationBlockchainTransactionStatusJob.set(wait_until: 5.minutes.from_now).perform_later(self)
  end
end
