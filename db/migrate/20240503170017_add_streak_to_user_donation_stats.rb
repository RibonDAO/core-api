class AddStreakToUserDonationStats < ActiveRecord::Migration[7.0]
  def change
    add_column :user_donation_stats, :streak, :integer, default: 0
  end
end
