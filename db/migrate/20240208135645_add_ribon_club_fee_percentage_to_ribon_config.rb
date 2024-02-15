class AddRibonClubFeePercentageToRibonConfig < ActiveRecord::Migration[7.0]
  def change
    add_column :ribon_configs, :ribon_club_fee_percentage, :decimal
  end
end
