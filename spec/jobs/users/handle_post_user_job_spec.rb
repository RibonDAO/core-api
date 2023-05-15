require 'rails_helper'

RSpec.describe Users::HandlePostUserJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(user:) }

    context 'when there is a legacy user associated with that email' do
      let!(:legacy_user) { create(:legacy_user, email: 'nicholas@ribon.io') }
      let!(:user) { create(:user, email: 'nicholas@ribon.io') }

      before do
        perform_job
      end

      it 'update the legacy user reference' do
        expect(user.reload.legacy_user).to eq(legacy_user)
      end
    end

    context 'when user has no legacy_user_impact' do
      let!(:user) { create(:user) }

      it 'do not update the legacy_id' do
        expect { perform_job }.not_to change(user, :legacy_id)
      end

      it 'do not update the legacy user' do
        expect(user.legacy_user).to be_nil
      end
    end
  end
end
