class SubscriptionBlueprint < Blueprinter::Base
  identifier :id

  fields :status, :cancel_date, :created_at

  field :next_payment_attempt do |object|
    object.last_club_day
  end

  association :offer, blueprint: OfferBlueprint, view: :plan
  association :receiver, blueprint: ->(receiver) { receiver.blueprint }, default: {}
  association :person_payments, blueprint: PersonPaymentBlueprint, view: :minimal
end
