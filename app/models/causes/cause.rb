# == Schema Information
#
# Table name: causes
#
#  id                      :bigint           not null, primary key
#  active                  :boolean          default(TRUE)
#  cover_image_description :string
#  main_image_description  :string
#  name                    :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class Cause < ApplicationRecord
  extend Mobility

  translates :name, :cover_image_description, :main_image_description, type: :string

  has_many :non_profits
  has_many :pools
  has_many :person_payments, as: :receiver
  has_many :subscriptions, as: :receiver

  has_one_attached :main_image
  has_one_attached :cover_image

  validates :name, presence: true

  before_save :deactivate_non_profits, if: :will_save_change_to_active?

  def default_pool
    pools.joins(:token).where(tokens: { chain_id: Chain.default&.id }).first
  end

  def with_pool_balance
    default_pool.respond_to?(:pool_balance) && default_pool&.pool_balance&.balance&.positive?
  end

  def blueprint
    CauseBlueprint
  end

  def deactivate_non_profits
    non_profits.where(status: :active).find_each { |n| n.update(status: :inactive) } unless active
  end
end
