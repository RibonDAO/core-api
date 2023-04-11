class FixCryptoValueCentsName < ActiveRecord::Migration[7.0]
  def change
    rename_column :person_payments, :crypto_value_cents, :usd_value_cents
  end
end
