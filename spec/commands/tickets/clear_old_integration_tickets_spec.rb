require 'rails_helper'

RSpec.describe Tickets::ClearOldIntegrationTickets do
  subject(:command) { described_class.call(time:) }

  let(:time) { 1.month.ago }

  before do
    create(:ticket, source: :integration, created_at: 2.months.ago)
    create(:ticket, source: :integration, created_at: 1.week.ago)
    create(:ticket, source: :club, created_at: 2.months.ago)
  end

  it 'deletes old tickets' do
    expect { command }.to change(Ticket, :count).from(3).to(2)
  end
end
