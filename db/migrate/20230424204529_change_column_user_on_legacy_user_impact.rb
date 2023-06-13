class ChangeColumnUserOnLegacyUserImpact < ActiveRecord::Migration[7.0]
  def change
    change_column_null :legacy_user_impacts, :user_id, true
  end
end
