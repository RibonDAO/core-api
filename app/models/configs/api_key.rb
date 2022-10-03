# == Schema Information
#
# Table name: api_keys
#
#  id           :bigint           not null, primary key
#  bearer_type  :string           not null
#  token_digest :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  bearer_id    :bigint           not null
#
class ApiKey < ApplicationRecord
  belongs_to :bearer, polymorphic: true

  HMAC_SECRET_KEY = RibonCoreApi.config[:hmac][:secret_key]

  before_create :generate_token_hmac_digest
  attr_accessor :token

  def self.authenticate_by_token!(token)
    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, token

    find_by! token_digest: digest
  end

  def self.authenticate_by_token(token)
    authenticate_by_token! token
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def serializable_hash(options = nil)
    h = super options.merge(except: 'token_digest')
    h['token'] = token if token.present?
    h
  end

  private

  def generate_token_hmac_digest
    raise ActiveRecord::RecordInvalid, 'token is required' if
      token.blank?

    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, token

    self.token_digest = digest
  end
end
