# frozen_string_literal: true

require 'rails_helper'

describe Tickets::CollectByIntegration do
  describe '.call' do
    subject(:command) { described_class.call(integration:, user:, platform: 'web') }

    context 'when no error occurs' do
      let(:integration) { create(:integration, ticket_availability_in_minutes: nil) }
      let(:user) { create(:user) }
      let(:command_stubbed) { class_double(Tickets::ClearCollectedByIntegrationJob) }

      before do
        allow(Tickets::ClearCollectedByIntegrationJob).to receive(:set).and_return(command_stubbed)
        allow(command_stubbed).to receive(:perform_later)
      end

      it 'creates a ticket in database' do
        expect { command }.to change(Ticket, :count).by(1)
      end

      it 'creates a UserIntegrationCollectedTicket in database' do
        expect { command }.to change(UserIntegrationCollectedTicket, :count).by(1)
      end

      it 'returns the ticket created' do
        expect(command.result).to eq user.tickets.last
      end

      context 'when integration has not ticket_availability_in_minutes' do
        it 'does not call the ClearCollectedByIntegrationJob' do
          command
          expect(command_stubbed).not_to have_received(:perform_later).with(integration, user)
        end
      end

      context 'when integration has ticket_availability_in_minutes' do
        before do
          integration.update(ticket_availability_in_minutes: 10)
        end

        it 'calls the ClearCollectedByIntegrationJob' do
          command
          expect(command_stubbed).to have_received(:perform_later).with(integration, user)
        end

        it 'sets the ClearCollectedByIntegrationJob' do
          command
          expect(Tickets::ClearCollectedByIntegrationJob).to have_received(:set)
        end
      end
    end

    context 'when an error occurs during the process' do
      let(:integration) { create(:integration) }
      let(:user) { create(:user) }

      before do
        allow(Ticket).to receive(:create!).and_raise(ActiveRecord::ConnectionNotEstablished)
      end

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
        expect(command.errors[:message]).to eq ['ActiveRecord::ConnectionNotEstablished']
      end
    end

    context 'when an error occurs at the validation process' do
      let(:integration) { create(:integration) }
      let(:user) { create(:user) }

      before do
        create(:user_integration_collected_ticket, user:, integration:)
      end

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
        expect(command.errors[:message]).to eq ['Unable to collect now.']
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
