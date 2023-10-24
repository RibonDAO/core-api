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

class Account < ApplicationRecord
  include AuthenticatableModel

  belongs_to :user

  validates :uid, uniqueness: { case_sensitive: true }

  delegate :email, to: :user
  delegate :unconfirmed_email, to: :user

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
