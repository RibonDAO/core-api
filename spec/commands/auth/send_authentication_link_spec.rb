# frozen_string_literal: true

require 'rails_helper'

describe Auth::SendAuthenticationLink do
  describe '.call' do
    subject(:command) { described_class.call(authenticatable:) }

    let(:authenticatable) { create(:big_donor) }
    let(:email_link_service) { instance_double(Auth::EmailLinkService, find_or_create_auth_link: auth_link) }
    let(:auth_link) { 'https://auth.ribon.io/link' }
    let(:event) do
      OpenStruct.new({
                       name: 'send_patron_authentication_link',
                       data: {
                         email: authenticatable.email,
                         url: auth_link
                       }
                     })
    end

    before do
      allow(EventServices::SendEvent).to receive(:new)
      allow(Auth::EmailLinkService).to receive(:new).and_return(email_link_service)
    end

    it 'sends an email with the authentication link with correct params' do
      command

      expect(EventServices::SendEvent).to have_received(:new).with(
        user: authenticatable,
        event:
      )
    end
  end
end
