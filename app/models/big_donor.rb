# == Schema Information
#
# Table name: big_donors
#
#  id         :uuid             not null, primary key
#  email      :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class BigDonor < ApplicationRecord
  include AuthenticatableModel

  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true

  before_validation { email.downcase! }

  has_many :person_payments, as: :payer
  has_many :contributions, through: :person_payments
  has_many :email_logs, as: :receiver

  def blueprint
    BigDonorBlueprint
  end

  def identification
    email
  end

  def dashboard_link
    Auth::EmailLinkService.new(authenticatable: self).find_or_create_auth_link
  end

  def language
    'en'
  end
end
