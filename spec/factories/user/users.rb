# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  email      :string
#  language   :integer          default("en")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  legacy_id  :integer
#
FactoryBot.define do
  factory :user do
    sequence :email, 100 do |n|
      "user-#{n}@example.com"
    end
  end
end
