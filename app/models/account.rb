# == Schema Information
#
# Table name: accounts
#
#  id                   :bigint           not null, primary key
#  confirmation_sent_at :datetime
#  confirmation_token   :string
#  confirmed_at         :datetime
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

class Account < ApplicationRecord
  include AuthenticatableModel

  belongs_to :user

  validates :uid, uniqueness: { case_sensitive: true }, presence: true

  delegate :email, to: :user

  def self.create_user_for_google(data)
    user = User.find_or_create_by(email: data['email'])
    account = find_or_initialize_by(user:)
    account.assign_attributes(
      provider: 'google_oauth2',
      uid: data['email']
    )
    account.save!
    account
  end
end
