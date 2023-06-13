class AddContributionFeePercentageToRibonConfigs < ActiveRecord::Migration[7.0]
  def change
    add_column :ribon_configs, :contribution_fee_percentage, :decimal
  end
end
