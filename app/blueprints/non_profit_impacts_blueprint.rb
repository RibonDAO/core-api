class NonProfitImpactsBlueprint < Blueprinter::Base
  fields :id, :end_date, :start_date, :usd_cents_to_one_impact_unit, :donor_recipient, :impact_description

  field :measurement_unit do |object|
    object.measurement_unit || 'quantity_without_decimals'
  end
end
