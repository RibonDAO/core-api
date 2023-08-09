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
FactoryBot.define do
  factory :big_donor do
    name { 'Yang' }
    sequence :email, 100 do |n|
      "bigdonor#{n}@example.com"
    end
  end
end
