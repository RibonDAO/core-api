class PersonPaymentCommunityCauseBlueprint < Blueprinter::Base
    identifier :id
  
    fields :paid_date, :crypto_amount, :amount_cents, :payment_method, :status, :external_id
  
    field :total_items do |_, options|
      options[:total_items]
    end
  
    field :page do |_, options|
      options[:page]
    end
  
    field :total_pages do |_, options|
      options[:total_pages]
    end
  
    association :receiver, blueprint: CauseBlueprint
  
    association :offer, blueprint: OfferBlueprint, view: :minimal
    
    association :person, blueprint: PersonBlueprint
  end
  