# == Schema Information
#
# Table name: plans
#
#  id              :bigint           not null, primary key
#  daily_tickets   :integer
#  monthly_tickets :integer
#  status          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  offer_id        :bigint           not null
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
