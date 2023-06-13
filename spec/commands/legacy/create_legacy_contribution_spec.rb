require 'rails_helper'

describe Legacy::CreateLegacyContribution do
  include ActiveStorage::Blob::Analyzable
  describe '.call' do
    subject(:command) { described_class.call(legacy_user:, legacy_contribution:) }

    context 'when all the data is valid' do
      let(:legacy_user) do
        {
          email: 'test@mail',
          legacy_id: 1,
          created_at: '2019-01-01T00:00:00.000Z'
        }
      end
      let(:legacy_contribution) do
        {
          created_at: '2023-05-15T09:26:52-03:00',
          value_cents: 500,
          legacy_payment_id: 1,
          legacy_payment_method: :credit_card,
          legacy_payment_platform: :iugu,
          from_subscription: true
        }
      end

      context 'when it has not been created' do
        it 'creates new legacy contribution' do
          expect { command }.to change(LegacyContribution, :count).by(1)
        end

        it 'add user reference if user exists' do
          user = create(:user, email: legacy_user[:email])
          command
          expect(LegacyContribution.first.legacy_user.user).to eq(user)
        end
      end

      context 'when it has already been created' do
        before do
          command
        end

        it 'does not legacy non profit' do
          expect { command }.not_to change(LegacyContribution, :count)
        end
      end
    end
  end
end
