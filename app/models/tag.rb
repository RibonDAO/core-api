# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  name       :string
#  status     :integer          default("inactive")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Tag < ApplicationRecord
  extend Mobility

  translates :name, type: :string

  has_many :non_profit_tags, dependent: :destroy
  has_many :non_profits, through: :non_profit_tags

  after_save :invalidate_cache

  enum status: {
    inactive: 0,
    active: 1,
    test: 2
  }

  validates :name, presence: true
  validates :status, presence: true

  accepts_nested_attributes_for :non_profit_tags, allow_destroy: true

  def invalidate_cache
    Rails.cache.delete_matched('active_tags_*')
  end
end
