class AddDaysDonatingToUserDonationStats < ActiveRecord::Migration[7.0]
  def change
    add_column :user_donation_stats, :days_donating, :integer, default: 0
  end
end
