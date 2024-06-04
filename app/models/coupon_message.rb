# == Schema Information
#
# Table name: coupon_messages
#
#  id          :bigint           not null, primary key
#  reward_text :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  coupon_id   :uuid             not null
#
class CouponMessage < ApplicationRecord
  extend Mobility

  belongs_to :coupon

  translates :reward_text, type: :string

  validates :reward_text, presence: true
end
