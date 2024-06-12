# frozen_string_literal: true

require 'rails_helper'

describe WarmglowMessages::UpsertWarmglowMessage do
  describe '.call' do
    subject(:command) { described_class.call(warmglow_message_params) }

    context 'when create with the right params' do
      let(:warmglow_message_params) do
        {
          message: 'message',
          status: 'active'
        }
      end

      context 'when create and have success' do
        it 'creates a new warmglow message' do
          command
          expect(WarmglowMessage.count).to eq(1)
        end
      end
    end

    context 'when update with the right params' do
      let(:warmglow_message) { create(:warmglow_message) }
      let(:warmglow_message_params) do
        {
          id: warmglow_message.id,
          message:'message 2',
          status: 'active'
        }
      end


      it 'updates the warmglow message with new message' do
        command
        expect(warmglow_message.reload.message).to eq('message 2')
      end
    end
  end
end
