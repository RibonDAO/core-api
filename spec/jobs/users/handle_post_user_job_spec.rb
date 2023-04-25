require 'rails_helper'

RSpec.describe Users::HandlePostUserJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(user:) }

    context 'when user has legacy_user_impact' do
      let!(:legacy_user_impact) { create(:legacy_user_impact, user_email: user.email) }
      let!(:user) { create(:user) }

      before do
        perform_job
      end

      it 'update the legacy_id' do
        expect(user.reload.legacy_id).to eq(legacy_user_impact.user_legacy_id)
      end

      it 'update the created_at' do
        expect(user.reload.created_at).to eq(legacy_user_impact.user_created_at)
      end
    end

    context 'when user has no legacy_user_impact' do
      let!(:user) { create(:user) }

      it 'do not update the legacy_id' do
        expect { perform_job }.not_to change(user, :legacy_id)
      end

      it 'do not update the created_at' do
        expect { perform_job }.not_to change(user, :created_at)
      end
    end
  end
end
