# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string
#  level      :integer          default(0)
#  language   :integer          default("en")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sash_id    :integer
#
class User < ApplicationRecord
  validates :email, uniqueness: { case_sensitive: true }, format: { with: URI::MailTo::EMAIL_REGEXP }

  enum language: {
    en: 0,
    'pt-BR': 1
  }

  before_validation { email.downcase! }
  after_create :set_user_donation_stats

  has_many :donations
  has_many :customers

  has_merit

  has_one :user_donation_stats
  has_one :utm, as: :trackable

  delegate :last_donation_at, to: :user_donation_stats
  delegate :can_donate?, to: :user_donation_stats
  delegate :last_donated_cause, to: :user_donation_stats

  scope :created_between, lambda { |start_date, end_date|
                            where('created_at >= ? AND created_at <= ?', start_date, end_date)
                          }

  def badges
    ::Badge.where(merit_badge_id: badge_ids).order(category: :asc).order(id: :asc)
  end

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

  private

  def set_user_donation_stats
    create_user_donation_stats unless user_donation_stats
  end
end
