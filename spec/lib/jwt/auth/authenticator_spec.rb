require 'rails_helper'

RSpec.describe ::Jwt::Auth::Authenticator do
  let(:jti) { SecureRandom.uuid }
  let(:exp) { 30.minutes.from_now.to_i }
  let(:authenticatable) { create(:user_manager) }
  let(:headers) do
    { Authorization: 'Bearer some_token' }
  end
  let(:access_token) { 'access_token' }

  describe '.call' do
    subject(:method_call) { described_class.call(headers:, access_token:) }

    context 'when there is no token' do
      let(:access_token) { nil }
      let(:headers) { {} }

      it 'raises MissingToken error' do
        expect { method_call }.to raise_error(Jwt::Errors::MissingToken)
      end
    end

    context 'when there is a valid token' do
      let(:decoded_token) do
        {
          jti:,
          authenticatable_id: authenticatable.id,
          authenticatable_type: authenticatable.class.name
        }
      end

      before do
        allow(Jwt::Auth::Decoder).to receive(:decode!).and_return(decoded_token)
        allow(Jwt::Auth::Allowlister).to receive(:allowlisted?).and_return(true)
      end

      it 'returns the authenticatable and the decoded token' do
        expect(method_call).to eq([authenticatable, decoded_token])
      end
    end

    context 'when there is an invalid token' do
      let(:decoded_token) do
        {
          jti:,
          authenticatable_id: nil,
          authenticatable_type: nil
        }
      end

      before do
        allow(Jwt::Auth::Decoder).to receive(:decode!).and_return(decoded_token)
      end

      it 'raises an invalid token error' do
        expect { method_call }.to raise_error(Jwt::Errors::InvalidToken)
      end
    end

    context 'when there is an invalid authenticatable from the token' do
      let(:decoded_token) do
        {
          jti:,
          authenticatable_id: authenticatable.id,
          authenticatable_type: authenticatable.class.name
        }
      end

      before do
        allow(Jwt::Auth::Decoder).to receive(:decode!).and_return(decoded_token)
        allow(Jwt::Auth::Allowlister).to receive(:allowlisted?).and_return(false)
      end

      it 'raises an unauthorized error' do
        expect { method_call }.to raise_error(Jwt::Errors::Unauthorized)
      end
    end
  end
end
