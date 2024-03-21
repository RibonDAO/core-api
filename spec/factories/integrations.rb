# == Schema Information
#
# Table name: integrations
#
#  id                             :bigint           not null, primary key
#  metadata                       :jsonb
#  name                           :string
#  status                         :integer          default("inactive")
#  ticket_availability_in_minutes :integer
#  unique_address                 :uuid             not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
FactoryBot.define do
  factory :integration do
    name { 'Renner' }
    status { :active }
    unique_address { 'f7be8d80-2406-4cb0-82eb-849346d327c9' }
    ticket_availability_in_minutes { nil }
    integration_wallet { build(:integration_wallet) }
    metadata { { user_id: 1 } }

    before(:create) do |integration|
      image_path = Rails.root.join('spec', 'factories', 'images', 'pitagoras.jpg')

      integration.logo.attach(io: File.open(image_path),
                              filename: 'pitagoras.jpg',
                              content_type: 'image/jpg')
    end

    after(:build) do |integration|
      image_path = Rails.root.join('spec', 'factories', 'images', 'pitagoras.jpg')

      integration.logo.attach(io: File.open(image_path),
                              filename: 'pitagoras.jpg',
                              content_type: 'image/jpg')
    end

    trait(:with_integration_task) do
      after(:create) do
        build(:integration_task)
      end
    end
  end
end
