class PersonPaymentBlueprint < Blueprinter::Base
  identifier :id

  fields :paid_date, :crypto_amount, :amount_cents, :payment_method, :status,
         :external_id, :service_fees, :payer_identification

  field :total_items do |_, options|
    options[:total_items]
  end

  field :page do |_, options|
    options[:page]
  end

  field :total_pages do |_, options|
    options[:total_pages]
  end

  association :offer, blueprint: OfferBlueprint, view: :minimal
  association :payer, blueprint: ->(payer) { payer.blueprint }, default: {}

  view :non_profit do
    association :receiver, blueprint: NonProfitBlueprint
  end

  view :cause do
    association :receiver, blueprint: CauseBlueprint
  end
end
