class ChangeIntegrationToOptionalInDonations < ActiveRecord::Migration[7.0]
  def change
    change_column_null :tickets, :integration_id, true
  end
end
