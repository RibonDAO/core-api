class AddDonorRecipientToNonProfitImpacts < ActiveRecord::Migration[7.0]
  def change
    add_column :non_profit_impacts, :donor_recipient, :string
  end
end
