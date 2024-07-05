class CouponBlueprint < Blueprinter::Base
  identifier :id
  fields :expiration_date, :available_quantity, :number_of_tickets, :link,
         :status

  association :coupon_message, blueprint: CouponMessageBlueprint
end
