require 'rails_helper'

RSpec.describe IntegrationBlueprint do
  let(:integration) { create(:integration) }
  let(:integration_blueprint) { described_class.render(integration) }

  it 'renders integration' do
    expect(integration_blueprint).to include(:name.to_s)
    expect(integration_blueprint).to include(:unique_address.to_s)
    expect(integration_blueprint).to include(:status.to_s)
    expect(integration_blueprint).to include(:integration_address.to_s)
    expect(integration_blueprint).to include(:ticket_availability_in_minutes.to_s)
    expect(integration_blueprint).to include(:webhook_url.to_s)
    expect(integration_blueprint).to include(:integration_dashboard_address.to_s)
  end
end
