class AddMeasurementUnitToNonProfitImpacts < ActiveRecord::Migration[7.0]
  def change
    add_column :non_profit_impacts, :measurement_unit, :string
  end
end
