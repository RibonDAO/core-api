# == Schema Information
#
# Table name: integrations
#
#  id                             :bigint           not null, primary key
#  name                           :string
#  status                         :integer          default("inactive")
#  ticket_availability_in_minutes :integer
#  unique_address                 :uuid             not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
class Integration < ApplicationRecord
  has_one :integration_wallet, as: :owner
  has_one :integration_task
  has_one :integration_webhook

  has_one_attached :logo

  accepts_nested_attributes_for :integration_task

  validates :name, :unique_address, :status, presence: true

  has_many :api_keys, as: :bearer
  has_many :donations
  has_many :vouchers
  has_many :person_payment
  has_many :user_integration_collected_tickets

  has_one :legacy_integration

  delegate :legacy_integration_impacts, to: :legacy_integration, allow_nil: true

  enum status: {
    inactive: 0,
    active: 1
  }

  def self.find_by_id_or_unique_address(id_or_address)
    return find_by(unique_address: id_or_address) if id_or_address.to_s.valid_uuid?

    find id_or_address
  end

  def integration_address
    "#{base_url}#{unique_address}"
  end

  def integration_dashboard_address
    "#{dashboard_base_url}#{unique_address}"
  end

  def integration_deeplink_address
    "#{deeplink_base_url}#{unique_address}"
  end

  def available_everyday_at_midnight?
    ticket_availability_in_minutes.nil?
  end

  def webhook_url
    integration_webhook&.url
  end

  def wallet_address
    integration_wallet&.public_key || ''
  end

  private

  def base_url
    RibonCoreApi.config[:integration_address][:base_url]
  end

  def dashboard_base_url
    RibonCoreApi.config[:integration_dashboard_address][:base_url]
  end

  def deeplink_base_url
    RibonCoreApi.config[:integration_deeplink_address][:base_url]
  end
end
