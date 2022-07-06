class Customer < ApplicationRecord
  include UuidHelper

  belongs_to :user
  has_many :customer_payments, dependent: :destroy

  validates :unique_address, presence: true
end
