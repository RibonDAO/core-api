require 'rails_helper'

RSpec.describe Tickets::ClearOldTickets do
  subject(:command) { described_class.call(time:) }

  let(:time) { 1.month.ago }

  before do
    create(:ticket, created_at: 2.months.ago)
    create(:ticket, created_at: 1.week.ago)
  end

  it 'deletes old tickets' do
    expect { command }.to change(Ticket, :count).from(2).to(1)
  end
end
