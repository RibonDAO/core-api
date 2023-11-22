# == Schema Information
#
# Table name: user_profiles
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
FactoryBot.define do
  factory :user_profile do
    user { build(:user) }
    name { 'MyString' }
  end
end
