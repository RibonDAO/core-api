require 'rails_helper'

RSpec.describe 'Users::V1::Tasks::Upsert', type: :request do
  describe 'POST users/v1/tasks/upsert/reset_streak' do
    include_context 'when making a user request' do
      subject(:request) { post '/users/v1/tasks/upsert/reset_streak', headers: }
    end

    let(:user) { account.user }
    let(:user_completed_task) { create(:user_completed_task, user:, last_completed_at: 1.day.ago) }

    context 'when exist user and dont have user task statistic' do
      before do
        user.user_tasks_statistic.destroy
      end

      it 'creates a user task statistic' do
        expect { request }.to change(UserTasksStatistic, :count).by(1)
      end
    end

    context 'when exist user and have user task statistic' do
      before do
        statistic = UserTasksStatistic.find_or_create_by(user:)
        statistic.update(streak: 10)
      end

      it 'does not create a user task statistic' do
        expect { request }.not_to change(UserTasksStatistic, :count)
      end

      it 'resets streak if no donation was found' do
        request
        expect(user.user_tasks_statistic.streak).to eq 0
      end
    end
  end

  describe 'POST /users/v1/tasks/upsert/complete_task' do
    include_context 'when making a user request' do
      subject(:request) do
        post '/users/v1/tasks/upsert/complete_task', headers:,
                                                     params: { task_identifier: 'task_identifier' }
      end
    end

    let(:user) { account.user }

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

  describe 'POST users/v1/tasks/upsert/first_completed_all_tasks' do
    include_context 'when making a user request' do
      subject(:request) { post '/users/v1/tasks/upsert/completed_all_tasks', headers: }
    end

    let(:user) { account.user }

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
