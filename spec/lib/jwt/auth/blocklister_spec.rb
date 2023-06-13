require 'rails_helper'

RSpec.describe ::Jwt::Auth::Blocklister do
  let(:jti) { SecureRandom.uuid }
  let(:exp) { 30.minutes.from_now.to_i }
  let(:authenticatable) { create(:user_manager) }

  describe '.blocklist!' do
    subject(:method_call) { described_class.blocklist!(jti:, exp:, authenticatable:) }

    it 'creates a new blocklisted token' do
      expect { method_call }.to change(authenticatable.blocklisted_tokens, :count).by(1)
    end
  end

  describe '.blocklisted?' do
    context 'when there is a block listed token' do
      before do
        described_class.blocklist!(jti:, exp:, authenticatable:)
      end

      it 'returns true' do
        expect(described_class.blocklisted?(jti:)).to be_truthy
      end
    end

    context 'when there is not a block listed token' do
      it 'returns false' do
        expect(described_class.blocklisted?(jti:)).to be_falsey
      end
    end
  end
end
