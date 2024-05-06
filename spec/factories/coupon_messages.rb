# == Schema Information
#
# Table name: coupon_messages
#
#  id                 :bigint           not null, primary key
#  reward_text        :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  coupon_id          :uuid             not null
#
FactoryBot.define do
  factory :coupon_message do
    reward_text { 'congratulations' }
    coupon { build(:coupon) }
  end
end
