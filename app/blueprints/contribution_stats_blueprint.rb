class ContributionStatsBlueprint < Blueprinter::Base
  fields :initial_amount, :used_amount, :remaining_amount, :total_tickets, :avg_donations_per_person,
         :boost_amount, :total_increase_percentage, :total_amount_to_cause, :ribon_fee
end
