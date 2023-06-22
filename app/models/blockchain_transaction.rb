# == Schema Information
#
# Table name: blockchain_transactions
#
#  id               :bigint           not null, primary key
#  owner_type       :string           not null
#  status           :integer          default("processing")
#  transaction_hash :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  chain_id         :bigint           not null
#  owner_id         :bigint           not null
#
class BlockchainTransaction < ApplicationRecord
  belongs_to :chain
  belongs_to :owner, polymorphic: true

  validates :transaction_hash, presence: true

  enum status: {
    processing: 0,
    success: 1,
    failed: 2,
    dropped: 3,
    replaced: 4
  }

  after_create :update_status_from_chain

  def transaction_link
    "#{chain.block_explorer_url}tx/#{transaction_hash}"
  end

  def update_status_from_chain
    # TODO: add listener to contract events to call this method
    Donations::UpdateBlockchainTransactionStatusJob.set(wait_until: 5.minutes.from_now).perform_later(self)
  end

  def retry?
    %w[failed dropped replaced].include?(status)
  end
end
