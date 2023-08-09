class ChangeLegacyContributionValueToValueCents < ActiveRecord::Migration[7.0]
  def change
    rename_column :legacy_contributions, :value, :value_cents
  end
end
