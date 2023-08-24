class SubscriptionBlueprint < Blueprinter::Base
  identifier :id

  fields :status, :cancel_date, :created_at

  association :offer, blueprint: OfferBlueprint, view: :minimal
  association :receiver, blueprint: ->(receiver) { receiver.blueprint }, default: {}

end
