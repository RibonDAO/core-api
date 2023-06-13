class AddMinimumContributionChargeableFeeCentsToRibonConfigs < ActiveRecord::Migration[7.0]
  def change
    add_column :ribon_configs, :minimum_contribution_chargeable_fee_cents, :integer
  end
end
