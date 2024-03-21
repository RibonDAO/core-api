require 'rails_helper'

RSpec.describe Tickets::ClearOldIntegrationTickets do
  subject(:command) { described_class.call(time:) }

  let(:time) { 1.month.ago }
  let(:integration) { create(:integration) }

  before do
    create(:user_integration_collected_ticket, integration:, created_at: 2.months.ago)
    create(:user_integration_collected_ticket, integration:, created_at: 1.week.ago)
  end

  it 'deletes old tickets' do
    expect { command }.to change(UserIntegrationCollectedTicket, :count).from(2).to(1)
  end
end
