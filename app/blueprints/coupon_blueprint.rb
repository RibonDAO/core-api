class CouponBlueprint < Blueprinter::Base
  identifier :id
  fields :expiration_date, :available_quantity, :number_of_tickets, :reward_text, :link,
         :ticket_availability_in_minutes, :status
end
