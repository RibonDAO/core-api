# frozen_string_literal: true

require 'rails_helper'

describe Tickets::GenerateClubTickets do
  describe '.call' do
    subject(:command) { described_class.call(source:, user:, platform: 'app', quantity:, category:) }

    context 'when no error occurs' do
      let(:integration) { create(:integration) }
      let(:source) { :club }
      let(:user) { create(:user) }
      let(:quantity) { 3 }
      let(:category) { :daily }

      it 'creates a ticket in database' do
        expect { command }.to change(Ticket, :count).by(3)
      end

      it 'user has 3 tickets' do
        command
        expect(user.tickets.count).to eq(3)
      end
    end
  end
end
