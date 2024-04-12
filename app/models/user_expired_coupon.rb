# == Schema Information
#
# Table name: user_expired_coupons
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  coupon_id  :uuid             not null
#  user_id    :bigint           not null
#
class UserExpiredCoupon < ApplicationRecord
  belongs_to :user
  belongs_to :coupon

  validates :user_id, uniqueness: { scope: :coupon_id }
end
