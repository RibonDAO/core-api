require 'rails_helper'

RSpec.describe 'Api::V1::Users::TasksStatistics', type: :request do
  describe 'GET users/tasks_statistics' do
    subject(:request) { get '/api/v1/users/tasks_statistics', headers: { Email: user.email } }

    let(:user) { create(:user) }
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

  describe 'POST users/tasks_statistics/first_completed_all_tasks' do
    subject(:request) do
      post '/api/v1/users/completed_all_tasks',
           headers: { Email: user.email }
    end

    let(:user) { create(:user) }

    context 'when exist user and dont complete tasks' do
      before do
        user
      end

      it 'returns the first_completed_all_tasks' do
        request

        expect_response_to_have_keys %w[first_completed_all_tasks_at streak contributor]
      end

      it 'add first time of completed all tasks' do
        request
        expect(user.user_tasks_statistic.reload.first_completed_all_tasks_at.to_date).to eq Time.zone.now.to_date
      end
    end
  end
end
