# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RedisStore::Cache do
  before { allow(RibonCoreApi).to receive(:redis).and_return(MockRedis.new) }

  describe '.find_or_create' do
    context 'when no expire time is passed' do
      before do
        described_class.find_or_create(key: :foo) { 'test' }
      end

      it 'does not cache' do
        expect(described_class.find_or_create(key: :foo) { 'fallback' }).to eq 'fallback'
      end
    end

    context 'when store value with expires time' do
      before do
        described_class.find_or_create(key: :foo, expires_in: 1.day) { 'test' }
      end

      context 'when the data is cached' do
        it 'gets the cached data' do
          expect(described_class.find_or_create(key: :foo, expires_in: 1.day) { 'fallback' }).to eq 'test'
        end
      end

      context 'when the data expired' do
        it 'gets the fallback block and caches' do
          allow(Time).to receive(:now).and_return(2.days.from_now)
          expect(described_class.find_or_create(key: :foo, expires_in: 1.day) { 'testing' }).to eq 'testing'
          expect(described_class
                   .find_or_create(key: :foo, expires_in: 1.day) { 'not reached fallback' }).to eq 'testing'
        end
      end
    end
  end

  describe '.find' do
    before do
      described_class.find_or_create(key: :foo, expires_in: 1.day) { 'test' }
    end

    context 'when the data is cached' do
      it 'gets the cached data' do
        expect(described_class.find(:foo)).to eq 'test'
      end
    end

    context 'when the data is not cached' do
      it 'returns nil' do
        expect(described_class.find(:bar)).to be_nil
      end
    end
  end
end
