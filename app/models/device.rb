class Device < ApplicationRecord
  belongs_to :user

  validates :device_id, :device_token, presence: true
  validates :device_id, uniqueness: { scope: :user_id }
end
