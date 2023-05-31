# frozen_string_literal: true

require 'rails_helper'

describe Users::UpsertTask do
  describe '.call' do
    subject(:command) do
      described_class.call(user:, task_identifier:)
    end

    context 'when has just user' do
      let(:user) { create(:user) }
      let(:task_identifier) { 'task_identifier' }

      it 'returns the task' do
        expect(command.result).to be_a(UserCompletedTask)
      end
    end

    context 'when has user and task' do
      let(:user) { create(:user) }
      let(:task_identifier) { 'task_identifier' }
      let!(:task) { create(:user_completed_task, user:, task_identifier:) }

      context 'when task is not done' do
        it 'returns the task' do
          expect(command.result).to be_a(UserCompletedTask)
        end

        it 'updates the task' do
          expect { command }.to change { task.reload.times_completed }.by(1)
        end
      end

      context 'when task is done' do
        before do
          task.update(last_completed_at: 1.day.ago)
        end

        it 'returns the task' do
          expect(command.result).to be_a(UserCompletedTask)
        end

        it 'updates the task' do
          expect { command }.to change { task.reload.times_completed }.by(1)
        end
      end
    end
  end
end
