class DonationBlockchainTransaction < ApplicationRecord
  belongs_to :donation
  belongs_to :chain

  enum status: {
    processing: 0,
    success: 1,
    failed: 2
  }
end
