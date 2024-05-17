# frozen_string_literal: true

require 'rails_helper'

describe Tags::UpsertTag do
  describe '.call' do
    subject(:command) { described_class.call(tag_params) }

    context 'when create with the right params' do
      let(:tag_params) do
        {
          name: 'tag',
          status: 'active',
          non_profit_tags_attributes: [{
            non_profit_id: create(:non_profit).id
          }]
        }
      end

      context 'when create and have success' do
        it 'creates a new tag' do
          command
          expect(Tag.count).to eq(1)
        end

        it 'creates a tag gateway' do
          command
          expect(NonProfitTag.count).to eq(1)
        end
      end
    end

    context 'when update with the right params' do
      let(:tag) { create(:tag) }
      let(:tag_params) do
        {
          id: tag.id,
          name: 'tag 2',
          status: 'active',
          non_profit_tags_attributes: [{
            non_profit_id: create(:non_profit).id
          }]

        }
      end

      it 'updates the tag with new name' do
        command
        expect(tag.reload.name).to eq('tag 2')
      end
    end
  end
end
