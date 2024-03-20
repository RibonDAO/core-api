# == Schema Information
#
# Table name: offers
#
#  id             :bigint           not null, primary key
#  active         :boolean
#  category       :integer          default("direct_contribution")
#  currency       :integer
#  position_order :integer
#  price_cents    :integer
#  subscription   :boolean
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
require 'rails_helper'

RSpec.describe Offer, type: :model do
  describe '.validations' do
    subject { build(:offer) }

    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_numericality_of(:price_cents).is_greater_than_or_equal_to(0) }
    it { is_expected.to have_one(:offer_gateway) }
    it { is_expected.to have_many(:plans) }
  end
end
