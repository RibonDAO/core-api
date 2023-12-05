# == Schema Information
#
# Table name: user_tasks_statistics
#
#  id                           :bigint           not null, primary key
#  first_completed_all_tasks_at :datetime
#  streak                       :integer          default(0)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  user_id                      :bigint           not null
#
require 'rails_helper'

RSpec.describe UserTasksStatistic, type: :model do
  let(:user) { create(:user) }
  let(:user_tasks_statistic) { build(:user_tasks_statistic, user:) }

  describe 'validations and associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe '#contributor' do
    context 'when user is a promoter' do
      before { allow(user).to receive(:promoter?).and_return(true) }

      it 'returns true' do
        expect(user_tasks_statistic.contributor).to be(true)
      end
    end

    context 'when user is not a promoter' do
      before { allow(user).to receive(:promoter?).and_return(false) }

      it 'returns false' do
        expect(user_tasks_statistic.contributor).to be(false)
      end
    end
  end
end
