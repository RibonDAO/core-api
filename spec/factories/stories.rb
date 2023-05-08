# == Schema Information
#
# Table name: stories
#
#  id                :bigint           not null, primary key
#  active            :boolean
#  description       :text
#  image_description :string
#  position          :integer
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  non_profit_id     :bigint           not null
#
FactoryBot.define do
  factory :story do
    title { 'Story' }
    description { 'Description' }
    non_profit_id { 1 }
    position { 1 }
    active { true }

    trait :with_image do
      after(:build) do |story|
        story.image.attach(io: Rails.root.join('vendor', 'assets', 'ribon_logo.png').open,
                           filename: 'ribon_logo.png', content_type: 'image/png')
      end
    end
  end
end
