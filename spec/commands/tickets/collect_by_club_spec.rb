# frozen_string_literal: true

require 'rails_helper'

describe Tickets::CollectByClub do
  describe '.call' do
    subject(:command) { described_class.call(user:, platform: 'app', category:) }

    context 'when no error occurs' do
      let(:user) { create(:user) }
      let(:category) { 'daily' }
      let!(:tickets) { create_list(:ticket, 3, source: :club, category:, status: :to_collect, user:) }

      it 'updates the tickets in database' do
        expect { command }.to change {
                                tickets.map(&:reload).map(&:status)
                              }.from(%w[to_collect to_collect to_collect]).to(%w[collected collected collected])
      end

      it 'returns the tickets collecteds with status updated' do
        expect(command.result).to eq(tickets.map(&:reload))
      end
    end

    context 'when an error occurs at the validation process' do
      let(:user) { create(:user) }
      let(:category) { 'daily' }

      it 'returns an error' do
        expect(command.errors).to be_present
      end

      it 'returns an error message' do
        expect(command.errors[:message]).to eq ['Unable to collect now.']
      end
    end
  end
end
