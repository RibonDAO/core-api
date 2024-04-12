class UserExpiredCoupon < ApplicationRecord
  belongs_to :user
  belongs_to :coupon

  validates :user_id, uniqueness: { scope: :coupon_id }
end
