class RemoveTicketAvailabilityFromCoupons < ActiveRecord::Migration[7.0]
  def change
    remove_column :coupons, :ticket_availability_in_minutes, :integer
  end
end
