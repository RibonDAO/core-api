class ContributionDirectImpactBlueprint < Blueprinter::Base
  field(:formatted_impact) do |object|
    object[:formatted_impact]
  end

  field(:total_amount_donated) do |object|
    object[:total_amount_donated]
  end

  field(:non_profit) do |object|
    NonProfitBlueprint.render_as_json(object[:non_profit])
  end
end
