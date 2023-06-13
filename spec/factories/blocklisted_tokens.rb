# == Schema Information
#
# Table name: blocklisted_tokens
#
#  id                   :bigint           not null, primary key
#  authenticatable_type :string           not null
#  exp                  :datetime
#  jti                  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  authenticatable_id   :bigint           not null
#
FactoryBot.define do
  factory :blocklisted_token do
    jti { 'MyString' }
    authenticatable { nil }
    exp { '2023-05-24 14:42:12' }
  end
end
