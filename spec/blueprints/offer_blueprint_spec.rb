require 'rails_helper'

RSpec.describe OfferBlueprint, type: :blueprint do
  let(:offer) { create(:offer) }
  let(:offer_blueprint) { described_class.render(offer) }
  let(:offer_blueprint_minimal) { described_class.render(offer, view: :minimal) }

  it 'has the correct fields' do
    expect(offer_blueprint).to include(:currency.to_s)
    expect(offer_blueprint).to include(:subscription.to_s)
    expect(offer_blueprint).to include(:price_cents.to_s)
    expect(offer_blueprint).to include(:price_value.to_s)
    expect(offer_blueprint).to include(:active.to_s)
    expect(offer_blueprint).to include(:title.to_s)
    expect(offer_blueprint).to include(:position_order.to_s)
    expect(offer_blueprint).to include(:external_id.to_s)
    expect(offer_blueprint).to include(:gateway.to_s)
  end

  it 'has the correct view' do
    expect(offer_blueprint_minimal).not_to include(:external_id.to_s)
    expect(offer_blueprint_minimal).not_to include(:gateway.to_s)
  end
end
