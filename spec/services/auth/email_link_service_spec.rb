require 'rails_helper'

RSpec.describe Auth::EmailLinkService, type: :service do
  subject(:service) { described_class.new(authenticatable:) }

  let(:authenticatable) { create(:big_donor) }

  describe '#find_or_create_auth_link' do
    context 'when there is already an auth token for that authenticatable' do
      let(:auth_token) { 'auth_token' }

      before do
        allow(SecureRandom).to receive(:uuid).and_return(auth_token)
        service.send(:generate_new_auth_token)
      end

      it 'returns the link with that auth token' do
        expect(service.find_or_create_auth_link)
          .to eq(
            "#{RibonCoreApi.config[:patrons][:app][:url]}/auth?authToken=#{auth_token}&id=#{authenticatable.id}"
          )
      end
    end

    context 'when there is no auth token' do
      let(:new_auth_token) { 'new_auth_token' }

      before do
        allow(SecureRandom).to receive(:uuid).and_return(new_auth_token)
      end

      it 'returns the link with a new auth token' do
        expect(service.find_or_create_auth_link).to eq(
          "#{RibonCoreApi.config[:patrons][:app][:url]}/auth?authToken=#{new_auth_token}&id=#{authenticatable.id}"
        )
      end
    end
  end

  describe '#valid_auth_token?' do
    let(:auth_token) { 'auth_token' }

    context 'when the token exists previously' do
      before do
        allow(SecureRandom).to receive(:uuid).and_return(auth_token)
        service.send(:generate_new_auth_token)
      end

      it 'returns true' do
        expect(service.valid_auth_token?(auth_token)).to be_truthy
      end

      context 'when the token is different from passed argument' do
        it 'returns false' do
          expect(service.valid_auth_token?('another_token')).to be_falsey
        end
      end
    end

    context 'when the token does not exist or is expired' do
      it 'returns false' do
        expect(service.valid_auth_token?(auth_token)).to be_falsey
      end
    end
  end
end
