class CreateContributionFees < ActiveRecord::Migration[7.0]
  def change
    create_table :contribution_fees do |t|
      t.references :contribution, null: false, foreign_key: true
      t.references :payer_contribution, null: false, index: true, foreign_key: {to_table: :contributions}
      t.integer :fee_cents

      t.timestamps
    end
  end
end
