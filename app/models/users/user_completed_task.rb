# == Schema Information
#
# Table name: user_completed_tasks
#
#  id                :uuid             not null, primary key
#  last_completed_at :datetime         not null
#  task_identifier   :string           not null
#  times_completed   :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :bigint           not null
#
class UserCompletedTask < ApplicationRecord
  belongs_to :user

  validates :task_identifier, presence: true

  def done?
    if daily?
      last_completed_at < next_day_at_midnight
    elsif monthly?
      last_completed_at < next_month_at_midnight
    else
      false
    end
  end

  def expires_at
    if done? && daily?
      next_day_at_midnight
    elsif done? && monthly?
      next_month_at_midnight
    else
      nil
    end
  end

  private

  def daily?
    task_identifier.split('-').first == 'daily'
  end

  def monthly?
    task_identifier.split('-').first == 'monthly'
  end

  def next_month_at_midnight
    last_time.next_month.midnight
  end

  def next_day_at_midnight
    last_time.tomorrow.midnight
  end

  def last_time
    last_completed_at.to_time
  end
end
