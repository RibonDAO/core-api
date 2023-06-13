require 'rails_helper'

RSpec.describe ::Jwt::Auth::Allowlister do
  let(:jti) { SecureRandom.uuid }
  let(:exp) { 30.minutes.from_now.to_i }
  let(:authenticatable) { create(:user_manager) }

  describe '.allowlist!' do
    subject(:method_call) { described_class.allowlist!(jti:, exp:, authenticatable:) }

    it 'creates a new allowlisted token' do
      expect { method_call }.to change(authenticatable.allowlisted_tokens, :count).by(1)
    end
  end

  describe '.remove_allowlist!' do
    subject(:method_call) { described_class.remove_allowlist!(jti:) }

    before do
      described_class.allowlist!(jti:, exp:, authenticatable:)
    end

    context 'when the token exists in the allow list' do
      it 'removes a token from the authenticatable' do
        expect { method_call }.to change(authenticatable.allowlisted_tokens, :count).by(-1)
      end

      it 'destroys the token' do
        method_call

        expect(described_class.allowlisted?(jti:)).to be_falsey
      end
    end
  end

  describe '.allowlisted?' do
    context 'when there is a allow listed token' do
      before do
        described_class.allowlist!(jti:, exp:, authenticatable:)
      end

      it 'returns true' do
        expect(described_class.allowlisted?(jti:)).to be_truthy
      end
    end

    context 'when there is not a allow listed token' do
      it 'returns false' do
        expect(described_class.allowlisted?(jti:)).to be_falsey
      end
    end
  end
end
