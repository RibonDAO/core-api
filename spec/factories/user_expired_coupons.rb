FactoryBot.define do
  factory :user_expired_coupon do
    user { build(:user) }
    coupon { build(:coupon) }
  end
end
