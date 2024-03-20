# == Schema Information
#
# Table name: impression_cards
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(FALSE)
#  client      :string
#  cta_text    :string           default(""), not null
#  cta_url     :string           default(""), not null
#  description :string           default(""), not null
#  headline    :string           default(""), not null
#  title       :string           default(""), not null
#  video_url   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe ImpressionCard, type: :model do
  describe '.validations' do
    subject { build(:impression_card) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:headline) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:cta_text) }
    it { is_expected.to validate_presence_of(:cta_url) }
    it { is_expected.to validate_presence_of(:client) }
  end
end
