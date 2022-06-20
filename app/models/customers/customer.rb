class Customer < ApplicationRecord
  include UuidHelper

  belongs_to :user
  has_many :payments, dependent: :destroy

  validates :email, presence: true
  validates :name, presence: true
end
