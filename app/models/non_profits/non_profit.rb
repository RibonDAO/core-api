# == Schema Information
#
# Table name: non_profits
#
#  id                             :bigint           not null, primary key
#  background_image_description   :string
#  confirmation_image_description :string
#  impact_description             :text
#  logo_description               :string
#  main_image_description         :string
#  name                           :string
#  status                         :integer          default("inactive")
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  cause_id                       :bigint
#
class NonProfit < ApplicationRecord
  extend Mobility

  translates :impact_description, type: :string, locale_accessors: %i[en pt-BR]
  translates :logo_description, type: :string, locale_accessors: %i[en pt-BR]
  translates :main_image_description, type: :string, locale_accessors: %i[en pt-BR]
  translates :background_image_description, type: :string, locale_accessors: %i[en pt-BR]
  translates :confirmation_image_description, type: :string, locale_accessors: %i[en pt-BR]

  has_one_attached :logo
  has_one_attached :main_image
  has_one_attached :background_image
  has_one_attached :confirmation_image

  has_many :non_profit_impacts
  has_many :non_profit_wallets, as: :owner

  has_many :non_profit_pools
  has_many :pools, through: :non_profit_pools
  has_many :stories, dependent: :delete_all
  has_many :person_payments, as: :receiver

  accepts_nested_attributes_for :stories
  accepts_nested_attributes_for :non_profit_impacts

  validates :name, :status, :wallet_address, presence: true

  belongs_to :cause

  before_save :save_wallet

  enum status: {
    inactive: 0,
    active: 1
  }

  def impact_for(date: Time.zone.now)
    non_profit_impacts.find_by('start_date <= ? AND end_date >= ?', date, date)
  end

  def impact_by_ticket(date: Time.zone.now)
    impact_for(date:)&.impact_by_ticket
  end

  def wallet_address
    if non_profit_wallets.where(status: :active).last
      non_profit_wallets.where(status: :active).last.public_key
    else
      non_profit_wallets.last&.active? ? non_profit_wallets.last.public_key : nil
    end
  end

  def wallet_address=(value)
    if non_profit_wallets.where(public_key: value).first
      @old_non_profit_wallet = non_profit_wallets.where(public_key: value).first
    else
      non_profit_wallets.new(
        public_key: value, status: :active
      )
    end
  end

  def save_wallet
    @old_non_profit_wallet&.update(status: :active)
  end
end
