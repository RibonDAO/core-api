module AuthenticatableModel
  extend ActiveSupport::Concern

  included do
    has_many :refresh_tokens, dependent: :delete_all, as: :authenticatable
    has_many :allowlisted_tokens, dependent: :delete_all, as: :authenticatable
    has_many :blocklisted_tokens, dependent: :delete_all, as: :authenticatable
  end

  def token_issued_at
    refresh_tokens.last&.created_at
  end
end
