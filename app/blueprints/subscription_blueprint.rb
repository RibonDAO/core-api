class SubscriptionBlueprint < Blueprinter::Base
  identifier :id

  fields :status, :cancel_date, :created_at, :next_payment_attempt

  association :offer, blueprint: OfferBlueprint, view: :minimal
  association :receiver, blueprint: ->(receiver) { receiver.blueprint }, default: {}
  association :person_payments, blueprint: PersonPaymentBlueprint, view: :minimal
end
