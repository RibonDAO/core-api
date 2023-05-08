# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  email      :string
#  language   :integer          default("en")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  legacy_id  :integer
#
class User < ApplicationRecord
  validates :email, uniqueness: { case_sensitive: true }, format: { with: URI::MailTo::EMAIL_REGEXP }

  enum language: {
    en: 0,
    'pt-BR': 1
  }

  before_validation { email.downcase! }
  after_create :set_user_donation_stats
  after_create :set_user_tasks_statistic

  has_many :donations
  has_many :customers
  has_many :user_completed_tasks
  has_many :legacy_user_impacts, dependent: :destroy

  has_one :user_donation_stats
  has_one :user_tasks_statistic
  has_one :utm, as: :trackable

  delegate :last_donation_at, to: :user_donation_stats
  delegate :can_donate?, to: :user_donation_stats
  delegate :last_donated_cause, to: :user_donation_stats
  delegate :first_completed_all_tasks_at, to: :user_tasks_statistic
  delegate :streak, to: :user_tasks_statistic

  scope :created_between, lambda { |start_date, end_date|
                            where('created_at >= ? AND created_at <= ?', start_date, end_date)
                          }

  def impact
    UserServices::UserImpact.new(user: self).impact
  end

  def last_contribution
    UserQueries.new(user: self).last_contribution
  end

  def last_contribution_at
    last_contribution&.paid_date
  end

  def self.users_that_last_contributed_in(date)
    UserQueries.users_that_last_contributed_in(date)
  end

  def promoter?
    !last_contribution.nil?
  end

  def donate_app
    return true if donations.where(platform: 'app').count.positive?

    false
  end

  private

  def set_user_donation_stats
    create_user_donation_stats unless user_donation_stats
  end

  def set_user_tasks_statistic
    create_user_tasks_statistic unless user_tasks_statistic
  end
end
