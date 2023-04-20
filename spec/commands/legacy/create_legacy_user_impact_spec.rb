require 'rails_helper'

describe Legacy::CreateLegacyUserImpact do
  describe '.call' do
    subject(:command) { described_class.call(email:, impacts:, legacy_id:) }

    context 'when all the data is valid and non existent' do
      let(:email) { 'test@mail' }
      let(:impacts) do
        [{
          non_profit: {
            name: 'Charity E',
            logo_url: 'https://example.com/charity-e.png',
            cost_of_one_impact: 5.99,
            impact_description: 'Provide shelter for a family',
            legacy_id: 456
          },
          total_impact: 3,
          total_donated_usd: 15,
          donations_count: 1
        }]
      end
      let(:legacy_id) { 11 }

      it 'creates legacy non profit' do
        expect { command }.to change(LegacyNonProfit, :count).by(1)
      end

      it 'creates new legacy user impact' do
        expect { command }.to change(LegacyUserImpact, :count).by(1)
      end

      it 'creates a new user' do
        expect { command }.to change(User, :count).by(1)
      end
    end
  end
end
