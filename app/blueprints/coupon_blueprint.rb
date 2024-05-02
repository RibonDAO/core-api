class CouponBlueprint < Blueprinter::Base
  identifier :id
  fields :expiration_date, :available_quantity, :number_of_tickets, :reward_text, :link,
         :status
end
