# frozen_string_literal: true

class UserQueries
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def last_contribution
    user.person_payments.order(paid_date: :asc).last
  end

  def self.users_that_last_contributed_in(date)
    customer_ids = PersonPayment.where(
      paid_date: date.all_day
    ).group(:payer_id, :payer_type).maximum(:paid_date).select { |_, v| v <= date }.keys
    user_ids = Customer.where(id: customer_ids).pluck(:user_id)

    User.where(id: user_ids)
  end

  def months_active
    DateRange::Helper.new(start_date: Time.zone.now, end_date: user.last_donation_at).months_difference
  end

  def total_donations_report
    user.donations.count
  end

  def labelable_contributions
    user.contributions.where(receiver_type: 'Cause').with_paid_status
  end
end
