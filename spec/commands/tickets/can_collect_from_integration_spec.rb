# frozen_string_literal: true

require 'rails_helper'

describe Tickets::CanCollectFromIntegration do
  describe '.call' do
    subject(:command) { described_class.call(integration:, user:) }

    context 'when no error occurs' do
      let(:integration) { create(:integration) }
      let(:user) { create(:user) }

      it 'returns the can collect true' do
        can_collect = command.result
        expect(can_collect).to be_truthy
      end
    end

    context 'when an error occurs at the validation process' do
      let(:integration) { create(:integration) }
      let(:user) { create(:user) }

      before do
        create(:user_integration_collected_ticket, user:, integration:)
      end

      it 'returns the can collect false' do
        can_collect = command.result
        expect(can_collect).to be_falsey
      end
    end

    context 'when user does not exist on database' do
      let(:integration) { build(:integration) }
      let(:user) { nil }

      it 'does not create the ticket on the database' do
        expect { command }.not_to change(Ticket, :count)
      end

      it 'does not create the UserIntegrationCollectedTicket on the database' do
        expect { command }.not_to change(UserIntegrationCollectedTicket, :count)
      end

      it 'returns an error' do
        expect(command.errors).to be_present
      end

      it 'returns an error message' do
        expect(command.errors[:message]).to eq ['User not found. Please logout and try again.']
      end
    end

    context 'when integration does not exist on database' do
      let(:integration) { nil }
      let(:user) { build(:user) }

      it 'does not create the ticket on the database' do
        expect { command }.not_to change(Ticket, :count)
      end

      it 'does not create the UserIntegrationCollectedTicket on the database' do
        expect { command }.not_to change(UserIntegrationCollectedTicket, :count)
      end

      it 'returns an error' do
        expect(command.errors).to be_present
      end

      it 'returns an error message' do
        expect(command.errors[:message]).to eq ['Integration not found. Please reload the page and try again.']
      end
    end
  end
end
