class ChangeProviderOnAccount < ActiveRecord::Migration[7.0]
  def change
    execute "UPDATE accounts SET provider = 'google' WHERE provider = 'google_oauth2_access'"
  end
end
