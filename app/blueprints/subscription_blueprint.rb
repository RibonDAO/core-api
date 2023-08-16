class SubscriptionBlueprint < Blueprinter::Base
  identifier :id

  association :person_payments, blueprint: PersonPaymentBlueprint
end
