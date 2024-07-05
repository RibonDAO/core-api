# == Schema Information
#
# Table name: ribon_configs
#
#  id                                        :bigint           not null, primary key
#  contribution_fee_percentage               :decimal(, )
#  default_ticket_value                      :decimal(, )
#  disable_labeling                          :boolean          default(FALSE)
#  minimum_contribution_chargeable_fee_cents :integer
#  minimum_version_required                  :string           default("0.0.0")
#  ribon_club_fee_percentage                 :decimal(, )
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  default_chain_id                          :integer
#
class RibonConfig < ApplicationRecord
  validate :singularity, on: :create
  validates :default_ticket_value, presence: true
  validates :default_chain_id, presence: true
  validates :contribution_fee_percentage, presence: true
  validates :ribon_club_fee_percentage, presence: true

  before_destroy :stop_destroy
  after_save :invalidate_cache

  def self.default_ticket_value
    first.default_ticket_value
  end

  def self.contribution_fee_percentage
    first.contribution_fee_percentage
  end

  def self.minimum_contribution_chargeable_fee_cents
    first.minimum_contribution_chargeable_fee_cents
  end

  def self.default_chain_id
    first&.default_chain_id
  end

  def self.disable_labeling
    first&.disable_labeling
  end

  def self.ribon_club_fee_percentage
    first&.ribon_club_fee_percentage
  end

  private

  def singularity
    raise StandardError, 'There can be only one.' if RibonConfig.count.positive?
  rescue StandardError => e
    errors.add(:message, e.message)
  end

  def stop_destroy
    errors.add(:base, :undestroyable)
    throw :abort
  end

  def invalidate_cache
    Rails.cache.delete_matched('active_non_profits_*')
    Rails.cache.delete_matched('active_tags_*')
  end
end
