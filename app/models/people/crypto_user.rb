# == Schema Information
#
# Table name: crypto_users
#
#  id             :uuid             not null, primary key
#  wallet_address :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  person_id      :uuid
#
class CryptoUser < ApplicationRecord
  include UuidHelper
  validates :wallet_address, presence: true

  belongs_to :person, optional: true

  has_many :person_payments, as: :payer

  def blueprint
    CryptoUserBlueprint
  end

  def identification
    wallet_address
  end
end
