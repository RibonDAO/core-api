# frozen_string_literal: true

require 'rails_helper'

describe Tickets::CollectByExternalId do
  describe '.call' do
    subject(:command) { described_class.call(integration:, user:, platform: 'web', external_ids:) }

    context 'when no error occurs' do
      let(:integration) { create(:integration) }
      let(:user) { create(:user) }
      let(:external_ids) { ['13'] }

      it 'creates a ticket in database' do
        expect { command }.to change(Ticket, :count).by(1)
      end

      it 'creates a voucher in database' do
        expect { command }.to change(Voucher, :count).by(1)
      end

      it 'returns the ticket created' do
        expect(command.result).to eq user.tickets.last
      end

      it 'returns the voucher created' do
        expect(command.result).to eq user.voucher.last
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

      it 'does not create the voucher on the database' do
        expect { command }.not_to change(Voucher, :count)
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

      it 'does not create the voucher on the database' do
        expect { command }.not_to change(Voucher, :count)
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

      it 'does not create the voucher on the database' do
        expect { command }.not_to change(Voucher, :count)
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
