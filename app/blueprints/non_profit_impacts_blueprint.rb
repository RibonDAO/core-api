class NonProfitImpactsBlueprint < Blueprinter::Base
  fields :id, :end_date, :start_date, :usd_cents_to_one_impact_unit, :donor_recipient, :impact_description

  field :measurement_unit do |object|
    object.measurement_unit || 'quantity_without_decimals'
  end

  field(:minimum_number_of_tickets) do |object|
    value = Integer(object.usd_cents_to_one_impact_unit / RibonConfig.default_ticket_value)
    if value.zero?
      1
    else
      value
    end
  end
end
