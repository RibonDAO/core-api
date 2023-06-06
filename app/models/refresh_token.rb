# == Schema Information
#
# Table name: refresh_tokens
#
#  id                   :bigint           not null, primary key
#  authenticatable_type :string           not null
#  crypted_token        :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  authenticatable_id   :bigint           not null
#
class RefreshToken < ApplicationRecord
  belongs_to :authenticatable, polymorphic: true

  before_create :set_crypted_token

  attr_accessor :token

  def self.find_by_token(token)
    crypted_token = Digest::SHA256.hexdigest token
    RefreshToken.find_by(crypted_token:)
  end

  private

  def set_crypted_token
    self.token = SecureRandom.hex
    self.crypted_token = Digest::SHA256.hexdigest(token)
  end
end
