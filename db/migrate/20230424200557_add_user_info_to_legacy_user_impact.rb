class AddUserInfoToLegacyUserImpact < ActiveRecord::Migration[7.0]
  def change
    add_column :legacy_user_impacts, :user_email, :string
    add_column :legacy_user_impacts, :user_legacy_id, :integer
    add_column :legacy_user_impacts, :user_created_at, :datetime
  end
end
