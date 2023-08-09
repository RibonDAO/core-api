# == Schema Information
#
# Table name: big_donors
#
#  id         :uuid             not null, primary key
#  email      :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe BigDonor, type: :model do
  describe '.validations' do
    subject { build(:big_donor) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
    it { is_expected.to have_many(:person_payments) }
  end
end
