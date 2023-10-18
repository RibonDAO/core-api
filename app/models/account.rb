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
  belongs_to :user

  before_validation { email.downcase! }

  validates :uid, uniqueness: { case_sensitive: true }

  include AuthenticatableModel
  include DeviseTokenAuth::Concerns::User

  delegate :email, to: :user

  def self.create_user_for_google(data)
    where(email: data['email']).first_or_initialize.tap do |user|
      user.provider = 'google_oauth2'
      user.uid = data['email']
      user.email = data['email']
      user.password = Devise.friendly_token[0, 20]
      user.password_confirmation = user.password
      user.save!
    end
  end
end
