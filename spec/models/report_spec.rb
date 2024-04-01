# == Schema Information
#
# Table name: reports
#
#  id         :bigint           not null, primary key
#  active     :boolean
#  link       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Report, :report, type: :model do
  describe '.validations' do
    subject { build(:report) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:link) }
    it { is_expected.to validate_presence_of(:active) }
  end
end
