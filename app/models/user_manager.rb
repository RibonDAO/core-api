# == Schema Information
#
# Table name: user_managers
#
#  id                     :bigint           not null, primary key
#  allow_password_change  :boolean          default(FALSE)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  image                  :string
#  name                   :string
#  nickname               :string
#  provider               :string           default("email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :json
#  uid                    :string           default(""), not null
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class UserManager < ApplicationRecord
  include DeviseTokenAuth::Concerns::User
  has_many :refresh_tokens, dependent: :delete_all, as: :authenticatable
  has_many :allowlisted_tokens, dependent: :delete_all, as: :authenticatable
  has_many :blocklisted_tokens, dependent: :delete_all, as: :authenticatable

  validates :email, uniqueness: { case_sensitive: true }, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation { email.downcase! }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

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
