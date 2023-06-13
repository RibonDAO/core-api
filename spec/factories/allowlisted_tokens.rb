# == Schema Information
#
# Table name: allowlisted_tokens
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
  factory :allowlisted_token do
    jti { 'MyString' }
    authenticatable { nil }
    exp { '2023-05-24 14:42:46' }
  end
end
