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
  include DeviseTokenAuth::Concerns::User

  belongs_to :user

  before_validation :downcase_email

  validates :uid, uniqueness: { case_sensitive: true }

  delegate :email, to: :user

  def self.create_user_for_google(data)
    user = User.find_or_initialize_by(email: data['email'])
    user ||= User.create!(
      email: data['email']
    )
    account = find_or_initialize_by(user:)
    account.assign_attributes(
      provider: 'google_oauth2',
      uid: data['email'],
      password: Devise.friendly_token[0, 20],
      password_confirmation: account.password
    )
    account.save!
    account
  end

  private

  def downcase_email
    email&.downcase!
  end
end
