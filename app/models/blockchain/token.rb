# == Schema Information
#
# Table name: tokens
#
#  id         :bigint           not null, primary key
#  address    :string
#  decimals   :integer
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  chain_id   :bigint
#
class Token < ApplicationRecord
  validates :name, :address, :decimals, presence: true

  belongs_to :chain
  has_many :pools

  def self.default
    default_chain_id = Chain.default&.id
    where(chain_id: default_chain_id).first
  end
end
