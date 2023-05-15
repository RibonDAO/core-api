require 'rails_helper'

describe Legacy::CreateLegacyUserImpact do
  include ActiveStorage::Blob::Analyzable
  describe '.call' do
    subject(:command) { described_class.call(legacy_user:, legacy_impacts:) }

    context 'when all the data is valid' do
      let(:legacy_user) do
        {
          email: 'test@mail',
          legacy_id: 1,
          created_at: '2019-01-01T00:00:00.000Z'
        }
      end
      let(:legacy_impacts) do
        [{
          non_profit: {
            name: 'Charity E',
            logo_url: 'https://charitye.com/logo.png',
            impact_cost_ribons: 1000,
            impact_cost_usd: 5.99,
            impact_description_en: 'Provide shelter for a family',
            impact_description_pt_br: 'Provide shelter for a family',
            legacy_id: 456
          },
          total_impact_en: 'Provide shelter for a family',
          total_impact_pt_br: 'Provide shelter for a family',
          total_donated_usd: 15,
          donations_count: 1
        }]
      end

      before do
        allow(URI).to receive(:open).and_return(File.open('vendor/assets/ribon_logo.png'))
      end

      context 'when it has not been created' do
        it 'creates legacy non profit' do
          expect { command }.to change(LegacyNonProfit, :count).by(1)
        end

        it 'creates new legacy user impact' do
          expect { command }.to change(LegacyUserImpact, :count).by(1)
        end

        it 'add user info if user does not exists' do
          command
          expect(LegacyUserImpact.first.legacy_user.email).to eq(legacy_user[:email])
          expect(LegacyUserImpact.first.legacy_user.legacy_id).to eq(legacy_user[:legacy_id])
          expect(LegacyUserImpact.first.legacy_user.created_at).to eq(legacy_user[:created_at])
        end

        it 'add user reference if user exists' do
          create(:user, email: legacy_user[:email])
          command
          expect(LegacyUserImpact.first.legacy_user.email).to eq(legacy_user[:email])
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
      end
    end
  end
end
