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
FactoryBot.define do
  factory :user_expired_coupon do
    user { build(:user) }
    coupon { build(:coupon) }
  end
end
