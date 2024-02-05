require 'rails_helper'

RSpec.describe PlanBlueprint, type: :blueprint do
  let(:plan) { create(:plan) }
  let(:plan_blueprint) { described_class.render(plan) }
  let(:offer) { plan.offer }

  it 'has the correct fields' do
    expect(plan_blueprint).to include(:daily_tickets.to_s)
    expect(plan_blueprint).to include(:monthly_tickets.to_s)
    expect(plan_blueprint).to include(:status.to_s)
    expect(plan_blueprint).to include(:offer.to_s)
  end
end
