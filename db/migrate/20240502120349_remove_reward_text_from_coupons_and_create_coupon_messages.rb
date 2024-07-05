class RemoveRewardTextFromCouponsAndCreateCouponMessages < ActiveRecord::Migration[7.0]
  def change
    remove_column :coupons, :reward_text, :string

    create_table :coupon_messages do |t|
      t.string :reward_text
      t.references :coupon, foreign_key: true, type: :uuid, null: false

      t.timestamps
    end
  end
end
