require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  describe 'POST /create' do
    subject(:request) { post '/api/v1/users', params: }

    context 'with right params' do
      let(:params) do
        {
          email: 'yan@ribon.io',
          language: 'en',
          utm_source: 'utm source',
          utm_medium: 'utm medium',
          utm_campaign: 'utm campaign'
        }
      end

      before do
        allow(Tracking::AddUtmJob).to receive(:perform_later)
      end

      it 'creates a new user in database' do
        expect { request }.to change(User, :count).by(1)
      end

      it 'heads http status created' do
        request

        expect(response).to have_http_status :created
      end

      it 'returns the user' do
        request

        expect_response_to_have_keys %w[created_at id email updated_at]
      end

      it 'calls add utm command' do
        request
        expect(Tracking::AddUtmJob).to have_received(:perform_later)
      end
    end

    context 'with wrong params' do
      let(:params) do
        {
          email: 'invalid_email'
        }
      end

      it 'does not create a new user in database' do
        expect { request }.not_to change(User, :count)
      end

      it 'heads http unprocessable_entity' do
        request

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'POST /users/search' do
    subject(:request) { post '/api/v1/users/search', params: { email: user.email } }

    context 'when the user exists' do
      let(:user) { create(:user) }

      before { user }

      it 'heads http status ok' do
        request

        expect(response).to have_http_status :ok
      end

      it 'returns the user' do
        request

        expect_response_to_have_keys %w[created_at id email updated_at last_donation_at last_donated_cause company
                                        direct_transfer_subscription]
      end
    end

    context 'when the user does not exist' do
      let(:user) { OpenStruct.new(email: 'nonexisting@user.com') }

      it 'heads http not found' do
        request

        expect(response).to have_http_status :not_found
      end

      it 'returns an error message' do
        request

        expect(response_body.error).to eq 'user not found'
      end
    end

    context 'when the user exists and has a direct_transfer subscription' do
      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:) }
      let(:integration) { create(:integration, name: 'Direct transfer integration') }
      let(:offer) { create(:offer, category: :business) }
      before do
        create(:subscription, payer: customer, payment_method: 'direct_transfer', integration:, status: :active, offer:)
      end

      it 'returns the company' do
        request
        expect(response_body.company).to be_present
        expect(response_body.company['name']).to eq 'Direct transfer integration'
      end

      it 'returns the direct_transfer_subscription' do
        request
        expect(response_body.direct_transfer_subscription).to be_present
        expect(response_body.direct_transfer_subscription['status']).to eq 'active'
      end
    end

    context 'when the user exists and does not have a direct_transfer subscription' do
      let(:user) { create(:user) }

      it 'returns the company as nil' do
        request
        expect(response_body.company).to be_nil
      end

      it 'returns the direct_transfer_subscription as nil' do
        request
        expect(response_body.direct_transfer_subscription).to be_nil
      end
    end
  end

  describe 'POST /users/can_donate' do
    subject(:request) do
      post '/api/v1/users/can_donate', headers: { Email: user.email }, params: { integration_id: integration.id }
    end

    let(:integration) { create(:integration) }
    let(:user) { create(:user) }

    it 'returns the can_donate attribute' do
      request

      expect_response_to_have_keys %w[can_donate donate_app]
    end
  end

  describe 'GET /users/donated_today' do
    subject(:request) do
      get '/api/v1/users/donated_today', headers: { Email: user.email }
    end

    let(:user) { create(:user) }

    it 'returns the donated_today attribute' do
      request

      expect_response_to_have_keys %w[donated_today]
    end
  end

  describe 'GET /users/completed_tasks' do
    subject(:request) { get '/api/v1/users/completed_tasks', headers: { Email: user.email } }

    let(:user) { create(:user) }
    let(:user_completed_task) { create(:user_completed_task, user:) }

    context 'when the user exists' do
      before do
        user
        user_completed_task
      end

      it 'heads http status ok' do
        request

        expect(response).to have_http_status :ok
      end

      it 'returns the user completed tasks' do
        request

        expect_response_collection_to_have_keys %w[id task_identifier last_completed_at times_completed done
                                                   expires_at]
      end
    end

    context 'when the user does not exist' do
      let(:user) { OpenStruct.new(email: 'dummyemail') }

      it 'heads http not found' do
        request

        expect(response).to have_http_status :not_found
      end

      it 'does not return the user completed tasks' do
        request

        expect(response_body).not_to respond_to :user_completed_tasks
      end
    end
  end

  describe 'POST /users/complete_task' do
    subject(:request) do
      post '/api/v1/users/complete_task', headers: { Email: user.email },
                                          params: { task_identifier: 'task_identifier' }
    end

    let(:user) { create(:user) }

    context 'when the user exists' do
      before { user }

      it 'heads http status ok' do
        request

        expect(response).to have_http_status :ok
      end

      it 'returns the user completed task' do
        request

        expect_response_to_have_keys %w[id task_identifier last_completed_at times_completed done expires_at]
      end

      it 'add a first time completed' do
        request

        expect(response_body.times_completed).to eq 1
      end
    end

    context 'when task is completed more than one time' do
      before do
        user
        create(:user_completed_task, user:, task_identifier: 'task_identifier', times_completed: 1)
      end

      it 'heads http status ok' do
        request

        expect(response).to have_http_status :ok
      end

      it 'returns the user completed task' do
        request

        expect_response_to_have_keys %w[id task_identifier last_completed_at times_completed done expires_at]
      end

      it 'add a first time completed' do
        request

        expect(response_body.times_completed).to eq 2
      end

      it 'do not create another task' do
        expect { request }.not_to change(UserCompletedTask, :count)
      end
    end
  end

  describe 'GET users/tasks_statistics/streak' do
    subject(:request) { get '/api/v1/users/tasks_statistics/streak', headers: { Email: user.email } }

    let(:user) { create(:user) }
    let(:user_completed_task) do
      create(:user_completed_task, user:, task_identifier: 'task_identifier', times_completed: 1)
    end
    let(:user_tasks_statistics) { create(:user_tasks_statistic, user:) }

    context 'when the user exists' do
      before do
        user
        user_completed_task
        user_tasks_statistics
      end

      it 'returns the user streak' do
        request

        expect_response_to_have_keys %w[streak]
      end
    end
  end

  describe 'POST /users/send_delete_account_email' do
    subject(:request) { post '/api/v1/users/send_delete_account_email', headers: { Email: user.email } }

    context 'when the user exists' do
      let(:user) { create(:user) }
      let(:jwt) { ::Jwt::Encoder.encode({ email: user.email }) }

      before do
        user
        allow(Events::Users::SendUserDeletionEmailJob).to receive(:perform_now)
      end

      it 'heads http status ok' do
        request

        expect(response).to have_http_status :ok
      end

      it 'call the job' do
        request

        expect(Events::Users::SendUserDeletionEmailJob).to have_received(:perform_now)
      end

      it 'returns the status' do
        request

        expect_response_to_have_keys %w[sent]
      end
    end

    context 'when the user does not exists' do
      let(:user) { OpenStruct.new(email: 'dummyemail') }

      it 'heads http status unauthorized' do
        request

        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'DELETE /users/destroy' do
    subject(:request) { delete '/api/v1/users', params: { token: } }

    let(:user) { create(:user, email: 'test@ribon.io', id: 2) }
    let(:token) { ::Jwt::Encoder.encode({ email: user.email }) }

    context 'when the user exists' do
      before do
        user
        allow(SecureRandom).to receive(:hex).and_return('dummy')
      end

      it 'heads http status ok' do
        request

        expect(response).to have_http_status :ok
      end

      it 'changes the user email' do
        request

        expect(user.reload.email).to eq 'deleted_user+2@ribon.io'
      end
    end

    context 'when email does not exist in the payload' do
      let(:user) { create(:user, email: 'test@ribon.io') }
      let(:token) { ::Jwt::Encoder.encode({ name: 'John' }) }

      it 'heads http status unauthorized' do
        request

        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when the user does not exists' do
      let(:user) { create(:user, email: 'test@ribon.io') }
      let(:token) { ::Jwt::Encoder.encode({ email: 'dummy@email.com' }) }

      it 'heads http status unprocessable_entity' do
        request

        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'when jwt is expired' do
      let(:user) { create(:user, email: 'test@ribon.io') }
      let(:token) { ::Jwt::Encoder.encode({ email: user.email }, -1.second) }

      it 'heads http status unauthorized' do
        request

        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
