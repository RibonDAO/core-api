RailsAdmin.config do |config|
  config.asset_source = :sprockets

  config.main_app_name = ["Ribon", "Admin"]
  config.parent_controller = RailsAdmin::RailsAdminAbstractController.to_s

  config.authenticate_with do
    # this is a rails controller helper
    authenticate_or_request_with_http_basic('Login required') do |email, password|

      # Here we're checking for username & password provided with basic auth
      resource = Admin.find_by(email: email)

      # we're using devise helpers to verify password and sign in the user
      if resource&.valid_password?(password)
        sign_in :admin, resource
      end
    end
  end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
  end

  config.included_models = [User, NonProfit, NonProfitImpact, Integration,
                            Donation, RibonConfig, GivingValue, Offer, OfferGateway,
                            Customer, PeoplePayment]

  config.model RibonConfig do
    field :default_ticket_value do
      label{ "ticket value in usdc cents" }
    end
  end

  config.model NonProfit do
    field :main_image do
      label{ "Cause Card Image" }
    end

    field :background_image do
      label{ "Support Image" }
    end

    field :logo do
      label{ "Logo" }
    end

    include_all_fields
  end

  MOBILITY_MODELS =  ApplicationRecord.descendants.select{ |model| model.included_modules.include?(Mobility::Plugins::Backend::InstanceMethods) }
  MOBILITY_MODELS.each do |model|
    config.model model do
      edit do
        formatted_mobility_attributes(model)
      end
      show do
        formatted_mobility_attributes(model)
      end

      list do
        fields do
          formatted_value{ bindings[:object].send(method_name) }
        end
      end
    end
  end

end

def formatted_mobility_attributes(model)
  model.mobility_attributes.each do |field_name|
    field field_name.to_sym do
      formatted_value{ bindings[:object].send(method_name) }
      help 'translation field'
      label do
        "#{label} (t)"
      end
    end
  end

  include_all_fields
end
