require 'rails_helper'

RSpec.describe 'Users::V1::Integrations', type: :request do
  describe 'POST /create' do
    include_context 'when making a user request' do
      let(:request) { post '/users/v1/integration', headers:, params: }
    end

    context 'when has no associated integration' do
      context 'when integration has partners branch' do
        let(:params) do
          {
            name: 'Ribon',
            status: 'active',
            metadata: { user_id: account.user.id, branch: 'partners' }
          }
        end

        it 'creates a new integration' do
          expect { request }.to change(Integration, :count).by(1)
        end

        it 'returns the created integration' do
          request

          expect_response_to_have_keys(%w[created_at id updated_at name status unique_address
                                          integration_address integration_wallet logo
                                          integration_task ticket_availability_in_minutes webhook_url
                                          integration_dashboard_address metadata onboarding_title
                                          onboarding_description banner_title banner_description
                                          onboarding_image])
        end
      end

      context 'when integration has referral branch' do
        let(:params) do
          {
            name: 'Ribon',
            status: 'active',
            metadata: { user_id: account.user.id, branch: 'referral' }
          }
        end

        it 'creates a new integration' do
          expect { request }.to change(Integration, :count).by(1)
        end

        it 'returns the created integration' do
          request

          expect_response_to_have_keys(%w[created_at id updated_at name status unique_address
                                          integration_address integration_wallet logo
                                          integration_task ticket_availability_in_minutes webhook_url
                                          integration_dashboard_address metadata onboarding_title
                                          onboarding_description banner_title banner_description
                                          onboarding_image])
        end
      end
    end

    context 'when has a partners associated integration' do
      context 'when creating a new partners integration' do
        let(:params) do
          {
            name: 'Ribon',
            status: 'active',
            metadata: { user_id: account.user.id, branch: 'partners' }
          }
        end

        before do
          create(
            :integration,
            metadata: { user_id: account.user.id, branch: 'partners' },
            name: 'Ribon',
            status: :active
          )
        end

        it 'does not create a new integration' do
          expect { request }.not_to change(Integration, :count)
        end

        it 'returns the existing integration' do
          request

          expect_response_to_have_keys(%w[created_at id updated_at name status unique_address
                                          integration_address integration_wallet logo
                                          integration_task ticket_availability_in_minutes webhook_url
                                          integration_dashboard_address metadata onboarding_title
                                          onboarding_description banner_title banner_description
                                          onboarding_image])
        end
      end

      context 'when creating a new referral integration' do
        let(:params) do
          {
            name: 'Ribon',
            status: 'active',
            metadata: { user_id: account.user.id, branch: 'referral' }
          }
        end

        before do
          create(
            :integration,
            metadata: { user_id: account.user.id, branch: 'partners' },
            name: 'Ribon',
            status: :active
          )
        end

        it 'creates a new integration' do
          expect { request }.to change(Integration, :count).by(1)
        end

        it 'returns the created integration' do
          request

          expect_response_to_have_keys(%w[created_at id updated_at name status unique_address
                                          integration_address integration_wallet logo
                                          integration_task ticket_availability_in_minutes webhook_url
                                          integration_dashboard_address metadata onboarding_title
                                          onboarding_description banner_title banner_description
                                          onboarding_image])
        end
      end
    end

    context 'when has a referral associated integration' do
      context 'when creating a new partners integration' do
        let(:params) do
          {
            name: 'Ribon',
            status: 'active',
            metadata: { user_id: account.user.id, branch: 'partners' }
          }
        end

        before do
          create(
            :integration,
            metadata: { user_id: account.user.id, branch: 'referral' },
            name: 'Ribon',
            status: :active
          )
        end

        it 'creates a new integration' do
          expect { request }.to change(Integration, :count).by(1)
        end

        it 'returns the created integration' do
          request

          expect_response_to_have_keys(%w[created_at id updated_at name status unique_address
                                          integration_address integration_wallet logo
                                          integration_task ticket_availability_in_minutes webhook_url
                                          integration_dashboard_address metadata onboarding_title
                                          onboarding_description banner_title banner_description
                                          onboarding_image])
        end
      end

      context 'when creating a new referral integration' do
        let(:params) do
          {
            name: 'Ribon',
            status: 'active',
            metadata: { user_id: account.user.id, branch: 'referral' }
          }
        end

        before do
          create(
            :integration,
            metadata: { user_id: account.user.id, branch: 'referral' },
            name: 'Ribon',
            status: :active
          )
        end

        it 'does not create a new integration' do
          expect { request }.not_to change(Integration, :count)
        end

        it 'returns the existing integration' do
          request

          expect_response_to_have_keys(%w[created_at id updated_at name status unique_address
                                          integration_address integration_wallet logo
                                          integration_task ticket_availability_in_minutes webhook_url
                                          integration_dashboard_address metadata onboarding_title
                                          onboarding_description banner_title banner_description
                                          onboarding_image])
        end
      end
    end
  end

  describe 'GET /show' do
    include_context 'when making a user request' do
      let(:request) { get '/users/v1/integration', headers:, params: }
    end

    let(:params) { { branch: 'referral' } }

    before do
      create(
        :integration,
        metadata: { user_id: account.user.id, branch: 'referral' },
        name: 'Ribon',
        status: :active
      )
    end

    it 'returns a single integration' do
      request

      expect_response_to_have_keys(%w[created_at id updated_at name status unique_address
                                      integration_address integration_wallet logo
                                      integration_task ticket_availability_in_minutes webhook_url
                                      integration_dashboard_address metadata onboarding_title
                                      onboarding_description banner_title banner_description
                                      onboarding_image])
    end
  end
end
