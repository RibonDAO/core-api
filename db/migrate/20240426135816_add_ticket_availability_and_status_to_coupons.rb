class AddTicketAvailabilityAndStatusToCoupons < ActiveRecord::Migration[7.0]
  def change
    add_column :coupons, :ticket_availability_in_minutes, :integer
    add_column :coupons, :status, :integer, default: 0
  end
end
