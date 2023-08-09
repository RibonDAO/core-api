# == Schema Information
#
# Table name: ribon_configs
#
#  id                                        :bigint           not null, primary key
#  contribution_fee_percentage               :decimal(, )
#  default_ticket_value                      :decimal(, )
#  minimum_contribution_chargeable_fee_cents :integer
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  default_chain_id                          :integer
#
class RibonConfig < ApplicationRecord
  validate :singularity, on: :create
  validates :default_ticket_value, presence: true
  validates :default_chain_id, presence: true
  validates :contribution_fee_percentage, presence: true

  before_destroy :stop_destroy

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
end
