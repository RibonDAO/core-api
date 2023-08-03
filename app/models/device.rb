class Device < ApplicationRecord
  belongs_to :user

  validates :device_token, uniqueness, presence: true
end
