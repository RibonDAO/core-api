FactoryBot.define do
  factory :integration do
    name { 'Renner' }
    status { :active }
    unique_address { 'f7be8d80-2406-4cb0-82eb-849346d327c9' }
    integration_wallet { build(:integration_wallet) }
  end
end
