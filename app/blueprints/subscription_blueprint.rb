class SubscriptionBlueprint < Blueprinter::Base
  identifier :id

  fields :status, :cancel_date

  association :person_payments, blueprint: PersonPaymentBlueprint, view: :subscription

end
