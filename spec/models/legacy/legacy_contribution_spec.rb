# == Schema Information
#
# Table name: legacy_contributions
#
#  id                      :bigint           not null, primary key
#  day                     :datetime
#  from_subscription       :boolean
#  legacy_payment_method   :integer
#  legacy_payment_platform :integer
#  value_cents             :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  legacy_payment_id       :integer
#  user_id                 :bigint           not null
#
require 'rails_helper'

RSpec.describe LegacyContribution, type: :model do
  describe '.validations' do
    subject { build(:legacy_contribution) }

    it { is_expected.to belong_to(:legacy_user) }
    it { is_expected.to validate_presence_of(:value_cents) }
    it { is_expected.to validate_presence_of(:day) }
    it { is_expected.to validate_presence_of(:legacy_payment_id) }
    it { is_expected.to validate_presence_of(:legacy_payment_platform) }
    it { is_expected.to validate_presence_of(:legacy_payment_method) }
  end
end
