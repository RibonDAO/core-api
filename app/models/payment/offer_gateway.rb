# == Schema Information
#
# Table name: offer_gateways
#
#  id          :bigint           not null, primary key
#  gateway     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  external_id :string
#  offer_id    :bigint           not null
#
class OfferGateway < ApplicationRecord
  belongs_to :offer, inverse_of: :offer_gateway
  validates :gateway, :external_id, presence: true

  enum gateway: {
    stripe: 0,
    stripe_global: 1
  }
end
