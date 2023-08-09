# == Schema Information
#
# Table name: pools
#
#  id         :bigint           not null, primary key
#  address    :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cause_id   :bigint
#  token_id   :bigint           not null
#
FactoryBot.define do
  factory :pool do
    address { '0xE00000000000000000000000000000000000000000000000' }
    token { build(:token) }
    name { 'Pool 1' }
    cause { build(:cause) }
  end
end
