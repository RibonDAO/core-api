# == Schema Information
#
# Table name: user_donation_stats
#
#  id                 :bigint           not null, primary key
#  last_donated_cause :bigint
#  last_donation_at   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :bigint           not null
#
class UserDonationStats < ApplicationRecord
  belongs_to :user

  def can_donate?(integration, platform)
    return true if next_donation_at(integration).nil? || user_first_donation_native(platform)

    Time.zone.now >= next_donation_at(integration)
  end

  def next_donation_at(integration)
    time_interval = integration.ticket_availability_in_minutes
    last_donation_at_to_integration = user_last_donation_to(integration)&.created_at

    if time_interval.present? && last_donation_at_to_integration.present?
      return last_donation_at_to_integration + time_interval.minutes
    end

    last_donation_at_to_integration&.next_day&.beginning_of_day
  end

  private

  def user_last_donation_to(integration)
    user.donations.where(integration:).order(created_at: :desc).first
  end

  def user_first_donation_native(platform)
    user.donations.where(platform: 'app').count.zero? && platform == 'app'
  end
end
