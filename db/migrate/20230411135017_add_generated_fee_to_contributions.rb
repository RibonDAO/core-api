class AddGeneratedFeeToContributions < ActiveRecord::Migration[7.0]
  def change
    add_column :contributions, :generated_fee_cents, :integer
  end
end
