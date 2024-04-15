class AddPlatformToUserCoupon < ActiveRecord::Migration[7.0]
  def change
    add_column :user_coupons, :platform, :string
  end
end
