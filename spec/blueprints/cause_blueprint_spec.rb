require 'rails_helper'

RSpec.describe CauseBlueprint, type: :blueprint do
  let(:cause) { create(:cause) }
  let(:cause_blueprint) { described_class.render(cause) }
  let(:cause_blueprint_minimal) { described_class.render(cause, view: :minimal) }

  it 'has the correct fields' do
    expect(cause_blueprint).to include(:name.to_s)
    expect(cause_blueprint).to include(:active.to_s)
  end

  it 'has the correct associations' do
    expect(cause_blueprint).to include(:pools.to_s)
    expect(cause_blueprint).to include(:non_profits.to_s)
  end

  it 'has the correct view' do
    expect(cause_blueprint_minimal).not_to include(:created_at.to_s)
    expect(cause_blueprint_minimal).not_to include(:updated_at.to_s)
  end
end
