# == Schema Information
#
# Table name: causes
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Cause < ApplicationRecord
  extend Mobility

  translates :name, type: :string

  has_many :non_profits
  has_many :pools
  has_many :person_payments, as: :receiver

  has_one_attached :main_image
  has_one_attached :cover_image

  validates :name, presence: true

  def default_pool
    pools.joins(:token).where(tokens: { chain_id: Chain.default&.id }).first
  end

  def active
    non_profits.where(status: :active).present?
  end
end
