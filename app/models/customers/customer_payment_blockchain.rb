class CustomerPaymentBlockchain < ApplicationRecord
  belongs_to :customer_payment

  enum treasure_entry_status: {
    processing: 0,
    success: 1,
    failed: 2
  }
end
