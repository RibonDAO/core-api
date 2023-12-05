# == Schema Information
#
# Table name: devices
#
#  id           :bigint           not null, primary key
#  device_token :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  device_id    :string
#  user_id      :bigint           not null
#
FactoryBot.define do
  factory :device do
    user { build(:user) }
    device_id { 'MyString' }
    device_token { 'MyString' }
  end
end
