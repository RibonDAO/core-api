class UserStatisticsBlueprint < Blueprinter::Base
  fields :total_causes, :total_non_profits, :total_donated, :total_tickets, :last_donated_non_profit,
         :last_donation_at
end
