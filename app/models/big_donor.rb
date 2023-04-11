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
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true

  before_validation { email.downcase! }

  has_many :person_payments, as: :payer

  def blueprint
    BigDonorBlueprint
  end

  def identification
    email
  end
end
