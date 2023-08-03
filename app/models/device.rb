class Device < ApplicationRecord
  belongs_to :user

  validates :device_token, presence: true, uniqueness: true
end
