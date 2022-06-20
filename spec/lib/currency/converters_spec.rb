require 'rails_helper'

RSpec.describe Currency::Converters do
  subject(:service) { described_class.new(value:, from:, to:) }

  let(:value) { 10 }
  let(:from) { 'USD' }
  let(:to) { 'BRL' }
  let(:add_rate) { Money.add_rate(from, to, 5) }

  before do
    mock_instance(klass: Currency::Rates, methods: { add_rate: })
  end

  describe '#convert' do
    it 'converts from usd to brl' do
      expect(service.convert.to_f).to eq 50
    end
  end
end
