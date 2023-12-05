# frozen_string_literal: true

require 'rails_helper'

describe Auth::Accounts::SendAuthenticationEmail do
  let(:integration) { create(:integration) }
  let(:command) do
    described_class.call(email: authenticatable.email,
                         id: nil,
                         current_email: authenticatable.email,
                         integration_id: integration.id)
  end
  let(:event_service_double) { instance_double(EventServices::SendEvent) }
  let(:authenticatable) { create(:account) }
  let(:email_link_service) { instance_double(Auth::EmailLinkService, find_or_create_auth_link: auth_link) }
  let(:auth_link) { 'https://auth.ribon.io/link' }

  before do
    allow(Auth::EmailLinkService).to receive(:new).and_return(email_link_service)
    allow(EventServices::SendEvent).to receive(:new).and_return(event_service_double)
    allow(event_service_double).to receive(:call)
  end

  describe 'when user have not received an extra ticket and it is the first access' do
    let(:url) { 'https://auth.ribon.io/link&extra_ticket=true' }
    let(:event) do
      OpenStruct.new({
                       name: 'authorize_email',
                       data: {
                         email: authenticatable.email,
                         new_user: true,
                         url:
                       }
                     })
    end

    it 'calls EventServices::SendEvent with correct arguments' do
      command
      expect(EventServices::SendEvent).to have_received(:new).with({ user: authenticatable.user,
                                                                     event: })
    end

    it 'calls EventServices::SendEvent call' do
      command
      expect(event_service_double).to have_received(:call)
    end

    it 'creates a profile' do
      expect { command }.to change(UserProfile, :count).by(1)
    end

    context 'when email and id is not present' do
      let(:command) { described_class.call(email: nil, id: nil, current_email: nil, integration_id: nil) }

      it 'does not call EventServices::SendEvent call' do
        command
        expect(event_service_double).not_to have_received(:call)
      end

      it 'returns a error message' do
        expect(command.errors[:message]).to eq(['Email or id must be present'])
      end
    end

    context 'when email and current email dont match' do
      let(:command) do
        described_class.call(email: authenticatable.email, id: nil, current_email: 'test1@email.com',
                             integration_id: nil)
      end

      it 'returns a error message' do
        expect(command.errors[:message]).to eq(['Email does not match'])
      end
    end
  end

  describe 'when user already received an extra ticket and it is not the first access' do
    let(:url) { 'https://auth.ribon.io/link' }
    let(:event) do
      OpenStruct.new({
                       name: 'authorize_email',
                       data: {
                         email: authenticatable.email,
                         new_user: false,
                         url:
                       }
                     })
    end

    before do
      create(:donation, user: authenticatable.user, integration:)
    end

    it 'calls EventServices::SendEvent with correct arguments' do
      command
      expect(EventServices::SendEvent).to have_received(:new).with({ user: authenticatable.user,
                                                                     event: })
    end

    it 'calls EventServices::SendEvent call' do
      command
      expect(event_service_double).to have_received(:call)
    end
  end
end
