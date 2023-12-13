# == Schema Information
#
# Table name: accounts
#
#  id                   :bigint           not null, primary key
#  confirmation_sent_at :datetime
#  confirmation_token   :string
#  confirmed_at         :datetime
#  deleted_at           :datetime
#  image                :string
#  name                 :string
#  nickname             :string
#  provider             :string
#  remember_created_at  :datetime
#  tokens               :json
#  uid                  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :bigint           not null
#
FactoryBot.define do
  factory :account do
    user { build(:user, email: 'user1@ribon.io') }
    confirmation_sent_at { '2023-10-11 15:10:00' }
    uid { 'user1@ribon.io' }
    provider { 'google' }
  end
end
