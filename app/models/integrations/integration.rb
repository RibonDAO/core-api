class Integration < ApplicationRecord
  has_one :integration_wallet

  enum status: { active: 0, inactive: 1 }

  validates :name, :status, :unique_address, presence: true

  def integration_address
    "https://dapp.ribon.io/integration/#{unique_address}"
  end
end
