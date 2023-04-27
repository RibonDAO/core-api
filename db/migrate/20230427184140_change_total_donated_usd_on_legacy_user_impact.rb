class ChangeTotalDonatedUsdOnLegacyUserImpact < ActiveRecord::Migration[7.0]
  def change
    change_column :legacy_user_impacts, :total_donated_usd, :decimal
  end
end
