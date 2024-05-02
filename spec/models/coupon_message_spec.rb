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
require 'rails_helper'

RSpec.describe CouponMessage, type: :model do
  describe '.validations' do
    subject { build(:coupon_message) }

    it { is_expected.to belong_to(:coupon) }
    it { is_expected.to validate_presence_of(:reward_text) }
  end
end
