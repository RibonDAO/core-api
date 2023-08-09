require 'rails_helper'

RSpec.describe NonProfitBlueprint, type: :blueprint do
  let(:non_profit) { create(:non_profit) }
  let(:non_profit_blueprint) { described_class.render(non_profit) }
  let(:non_profit_blueprint_no_cause) { described_class.render(non_profit, view: :no_cause) }

  it 'has the correct fields' do
    expect(non_profit_blueprint).to include(:name.to_s)
    expect(non_profit_blueprint).to include(:wallet_address.to_s)
    expect(non_profit_blueprint).to include(:impact_description.to_s)
    expect(non_profit_blueprint).to include(:status.to_s)
  end

  it 'renders the no cause view correctly' do
    expect(non_profit_blueprint_no_cause).not_to include(:cause.to_s)
  end
end
