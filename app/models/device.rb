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

  validates :device_token, presence: true, uniqueness: true
end
