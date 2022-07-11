class Guest < ApplicationRecord
  include UuidHelper

  belongs_to :people, optional: true 
  validates :wallet_address, presence: true
end
