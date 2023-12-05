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

    trait :with_image do
      after(:build) do |user_profile|
        user_profile.photo.attach(io: Rails.root.join('vendor', 'assets', 'ribon_logo.png').open,
                                  filename: 'ribon_logo.png', content_type: 'image/png')
      end
    end
  end
end
