require 'rails_helper'

RSpec.describe 'Users::V1::Tasks::Statistics', type: :request do
  describe 'GET users/tasks/statistics' do
    include_context 'when making a user request' do
      subject(:request) { get '/users/v1/tasks/statistics', headers: }
    end

    let(:user) { account.user }
    let(:user_tasks_statistics) { create(:user_tasks_statistic, user:) }

    context 'when the user exists' do
      before do
        user
        user_tasks_statistics
      end

      it 'returns the user streak' do
        request

        expect_response_to_have_keys %w[first_completed_all_tasks_at streak contributor]
      end
    end
  end

  describe 'GET users/v1/tasks/statistics/streak' do
    include_context 'when making a user request' do
      subject(:request) { get '/users/v1/tasks/statistics/streak', headers: }
    end

    let(:user) { account.user }
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

  describe 'GET /users/v1/tasks/statistics/completed_tasks' do
    include_context 'when making a user request' do
      subject(:request) { get '/users/v1/tasks/statistics/completed_tasks', headers: }
    end

    let(:user_completed_task) { create(:user_completed_task, user:) }

    context 'when the user exists' do
      let(:user) { account.user }

      before do
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
  end
end
