# == Schema Information
#
# Table name: user_coupons
#
#  id         :bigint           not null, primary key
#  platform   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  coupon_id  :uuid             not null
#  user_id    :bigint           not null
#
FactoryBot.define do
  factory :user_coupon do
    user { build(:user) }
    coupon { build(:coupon) }
  end
end
