class RemoveUserFromLegacyModels < ActiveRecord::Migration[7.0]
  def change
    remove_reference :legacy_user_impacts, :user, index: true, foreign_key: true
    remove_reference :legacy_contributions, :user, index: true, foreign_key: true
  end
end
