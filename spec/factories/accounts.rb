# == Schema Information
#
# Table name: accounts
#
#  id                     :bigint           not null, primary key
#  allow_password_change  :boolean
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  encrypted_password     :string
#  image                  :string
#  name                   :string
#  nickname               :string
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :json
#  uid                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :bigint           not null
#
FactoryBot.define do
  factory :account do
    user { build(:user, email: 'user1@ribon.io') }
    allow_password_change { false }
    confirmation_sent_at { '2023-10-11 15:10:00' }
    confirmed_at { '2023-10-11 15:10:00' }
    uid { 'user1@ribon.io' }
    provider { 'google_oauth2' }
  end
end
