class OfferBlueprint < Blueprinter::Base
  identifier :id

  fields :currency, :subscription, :price_cents, :price_value, :active, :title, :position_order,
         :created_at, :updated_at, :external_id, :gateway, :category

  field :price do |object|
    Money.new(object.price_cents, object.currency).format
  end

  view :plan do
    association :plan, blueprint: PlanBlueprint do |object|
      object.plan
    end
    excludes :external_id
  end

  view :manager do
    association :plan, blueprint: PlanBlueprint do |object|
      object.plan
    end
  end

  view :minimal do
    excludes :external_id
  end
end
