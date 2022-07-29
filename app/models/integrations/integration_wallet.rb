class IntegrationWallet < ApplicationRecord
  belongs_to :integration

  validates :public_key, :encrypted_private_key, :private_key_iv, presence: true
end
