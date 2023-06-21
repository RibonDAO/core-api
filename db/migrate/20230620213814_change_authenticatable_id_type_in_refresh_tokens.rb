class ChangeAuthenticatableIdTypeInRefreshTokens < ActiveRecord::Migration[7.0]
  def change
    change_column :refresh_tokens, :authenticatable_id, :string
  end
end
