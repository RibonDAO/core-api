# == Schema Information
#
# Table name: devices
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint
#  device_id      :string
#  device_token   :string
#
FactoryBot.define do
  factory :device do
    user { build(:user) }
    device_id { 'MyString' }
    device_token { 'MyString' }
  end
end
