class IntegrationImpactBlueprint < Blueprinter::Base
  fields :total_donations, :total_donors,
         :impact_per_non_profit, :donations_per_non_profit, :donors_per_non_profit,
         :previous_total_donations, :previous_total_donors,
         :previous_impact_per_non_profit, :previous_donations_per_non_profit, :previous_donors_per_non_profit,
         :total_donations_balance, :total_donors_balance,
         :total_donations_trend, :total_donors_trend,
         :total_new_donors, :total_donors_recurrent

  field :impact_per_non_profit do |object|
    object[:impact_per_non_profit].map do |impact|
      { non_profit: NonProfitBlueprint
        .render_as_hash(impact[:non_profit], view: :no_cause), impact: impact[:impact] }
    end
  end

  field :previous_impact_per_non_profit do |object|
    object[:previous_impact_per_non_profit].map do |impact|
      { non_profit: NonProfitBlueprint
        .render_as_hash(impact[:non_profit], view: :no_cause), impact: impact[:impact] }
    end
  end

  field :donations_per_non_profit do |object|
    object[:donations_per_non_profit].map do |donations|
      { non_profit: NonProfitBlueprint
        .render_as_hash(donations[:non_profit], view: :no_cause), donations: donations[:donations] }
    end
  end

  field :previous_donations_per_non_profit do |object|
    object[:previous_donations_per_non_profit].map do |donations|
      { non_profit: NonProfitBlueprint
        .render_as_hash(donations[:non_profit], view: :no_cause), donations: donations[:donations] }
    end
  end

  field :donors_per_non_profit do |object|
    object[:donors_per_non_profit].map do |donors|
      { non_profit: NonProfitBlueprint
        .render_as_hash(donors[:non_profit], view: :no_cause), donors: donors[:donors] }
    end
  end

  field :previous_donors_per_non_profit do |object|
    object[:previous_donors_per_non_profit].map do |donors|
      { non_profit: NonProfitBlueprint
        .render_as_hash(donors[:non_profit], view: :no_cause), donors: donors[:donors] }
    end
  end
end
