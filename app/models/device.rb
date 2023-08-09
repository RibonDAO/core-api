# == Schema Information
#
# Table name: devices
#
#  id           :bigint           not null, primary key
#  device_token :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  device_id    :string
#  user_id      :bigint           not null
#
class Device < ApplicationRecord
  belongs_to :user

  validates :device_id, :device_token, presence: true
  validates :device_id, uniqueness: { scope: :user_id }
end
