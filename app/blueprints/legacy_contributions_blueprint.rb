class LegacyContributionsBlueprint < Blueprinter::Base
  identifier :id
  fields :legacy_user_id, :value_cents, :day, :legacy_payment_id, :legacy_payment_platform,
         :legacy_payment_method, :from_subscription, :created_at, :updated_at

  field :value do |object|
    Money.new(object.value_cents, object.currency).format
  end
end
