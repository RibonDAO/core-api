# == Schema Information
#
# Table name: pools
#
#  id             :bigint           not null, primary key
#  address        :string
#  name           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  cause_id       :bigint
#  integration_id :bigint           not null
#  token_id       :bigint           not null
#
class Pool < ApplicationRecord
  extend Mobility

  translates :name, type: :string

  validates :address, :name, presence: true

  belongs_to :token
  belongs_to :cause

  has_many :non_profit_pools
  has_many :non_profits, through: :non_profit_pools

  delegate :chain, to: :token
end
