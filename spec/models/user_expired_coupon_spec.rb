require 'rails_helper'

RSpec.describe UserExpiredCoupon, type: :model do
  describe '.validations' do
    subject { build(:user_expired_coupon) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:coupon) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:coupon_id) }
  end
end
