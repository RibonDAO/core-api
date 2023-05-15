class AddLegacyUserToLegacyUserImpacts < ActiveRecord::Migration[7.0]
  def change
    add_reference :legacy_user_impacts, :legacy_user, foreign_key: true
  end
end
