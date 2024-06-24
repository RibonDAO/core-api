# frozen_string_literal: true

require 'rails_helper'

describe Tickets::CanCollectByExternalIds do
  describe '.call' do
    subject(:command) { described_class.call(external_ids:) }

    let(:external_ids) { ['13'] }

    context 'when no error occurs' do
      it 'returns the can collect true' do
        can_collect = command.result[:can_collect]
        expect(can_collect).to be_truthy
      end

      it 'returns the quantity of tickets' do
        quantity = command.result[:quantity]
        expect(quantity).to eq 1
      end
    end

    context 'when an error occurs at the validation process' do
      before do
        create(:voucher, external_id: '13')
      end

      it 'returns the can collect false' do
        can_collect = command.result[:can_collect]
        expect(can_collect).to be_falsey
      end

      it 'returns the quantity of tickets' do
        quantity = command.result[:quantity]
        expect(quantity).to eq 0
      end
    end
  end
end
