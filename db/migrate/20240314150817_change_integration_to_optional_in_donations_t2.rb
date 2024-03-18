class ChangeIntegrationToOptionalInDonationsT2 < ActiveRecord::Migration[7.0]
  def change
    change_column_null :donations, :integration_id, true
  end
end
