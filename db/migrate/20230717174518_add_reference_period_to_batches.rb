class AddReferencePeriodToBatches < ActiveRecord::Migration[7.0]
  def change
    add_column :batches, :reference_period, :date
  end
end
