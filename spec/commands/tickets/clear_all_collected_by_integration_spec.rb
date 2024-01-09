# frozen_string_literal: true

require 'rails_helper'

describe Tickets::ClearAllCollectedByIntegration do
  describe '.call' do
    subject(:command) { described_class.call(integration:) }

    let(:integration) { create(:integration) }

    context 'when no error occurs' do
      before do
        create(:user_integration_collected_ticket, integration:)
      end

      it 'deletes user_integration_collected_ticket from database' do
        expect { command }.to change(UserIntegrationCollectedTicket, :count).from(1).to(0)
      end
    end

    context 'when user_integration_collected_ticket does not exist on database' do
      it 'does not delete user_integration_collected_ticket from database' do
        expect { command }.not_to change(UserIntegrationCollectedTicket, :count)
      end
    end
  end
end
