require 'rails_helper'

describe Legacy::CreateLegacyUserImpact do
  describe '.call' do
    subject(:command) { described_class.call(email:, impacts:, legacy_id:) }

    context 'when all the data is valid' do
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

      context 'when it has not been created' do
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

      context 'when it has already been created' do
        before do
          command
        end

        it 'does not legacy non profit' do
          expect { command }.not_to change(LegacyNonProfit, :count)
        end

        it 'does not new legacy user impact' do
          expect { command }.not_to change(LegacyUserImpact, :count)
        end

        it 'does not a new user' do
          expect { command }.not_to change(User, :count)
        end
      end
    end
  end
end
