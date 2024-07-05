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
require 'rails_helper'

RSpec.describe UserCoupon, type: :model do
  describe '.validations' do
    subject { build(:user_coupon) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:coupon) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:coupon_id) }
  end
end
