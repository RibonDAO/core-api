# == Schema Information
#
# Table name: batches
#
#  id               :bigint           not null, primary key
#  amount           :decimal(, )
#  cid              :string
#  reference_period :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require 'rails_helper'

RSpec.describe Batch, type: :model do
  describe '.validations' do
    subject { build(:batch) }

    it { is_expected.to validate_presence_of(:cid) }
  end
end
