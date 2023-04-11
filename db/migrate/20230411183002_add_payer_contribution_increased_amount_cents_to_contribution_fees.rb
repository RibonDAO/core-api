class AddPayerContributionIncreasedAmountCentsToContributionFees < ActiveRecord::Migration[7.0]
  def change
    add_column :contribution_fees, :payer_contribution_increased_amount_cents, :integer
  end
end
