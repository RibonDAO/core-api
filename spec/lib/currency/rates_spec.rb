require 'rails_helper'

RSpec.describe Currency::Rates do
  subject(:service) { described_class.new(from:, to:) }

  let(:from) { 'USD' }
  let(:to) { 'BRL' }

  before do
    VCR.insert_cassette 'conversion_rate_usd_brl'
    allow(Money).to receive(:add_rate)
  end

  after do
    VCR.eject_cassette
  end

  describe '#rate' do
    it 'gets the conversion rate' do
      expect(service.rate).to eq '4.7637'
    end
  end

  describe 'add_rate' do
    it 'calls money gem with correct params' do
      service.add_rate

      expect(Money).to have_received(:add_rate).with(from, to, '4.7637')
    end
  end
end
