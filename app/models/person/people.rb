class People < ApplicationRecord
  include UuidHelper

  has_one :guest, dependent: :destroy
  has_one :customer, dependent: :destroy
  has_many :people_payments, dependent: :destroy
end
