# frozen_string_literal: true

require 'rails_helper'

describe Articles::CreateArticle do
  describe '.call' do
    subject(:command) { described_class.call(article_params) }

    context 'when create with the right params' do
      let(:article_params) do
        {
          title: 'New article',
          published_at: Time.zone.now,
          visible: true,
          author_id: create(:author).id,
          language: 'en-US'
        }
      end

      context 'when create and have success' do
        it 'creates a new article' do
          command
          expect(Article.count).to eq(1)
        end
      end
    end
  end
end
