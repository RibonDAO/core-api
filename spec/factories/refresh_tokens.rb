# == Schema Information
#
# Table name: refresh_tokens
#
#  id                   :bigint           not null, primary key
#  authenticatable_type :string           not null
#  crypted_token        :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  authenticatable_id   :string           not null
#
FactoryBot.define do
  factory :refresh_token do
    crypted_token { 'MyString' }
    authenticatable { nil }
  end
end
