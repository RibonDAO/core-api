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

  config.included_models = [Admin, Account, Customer, UserManager, User, UserProfile, UserTasksStatistic, NonProfit, NonProfitImpact, Integration,
                            Batch, Donation, DonationBatch, RibonConfig, Offer, OfferGateway,
                            Customer, PersonPayment, BlockchainTransaction, DonationBlockchainTransaction, Chain,
                            Cause, Story, NonProfitPool, IntegrationTask, CryptoUser, Contribution,
                            Voucher, IntegrationWebhook, Token, Pool, PoolBalance, History, BalanceHistory,
                            LegacyUserImpact, LegacyNonProfit, Article, Author, LegacyContribution, ContributionFee,
                            ContributionBalance, PersonBlockchainTransaction, DonationContribution, BigDonor,
                            LegacyUser, LegacyIntegrationImpact, LegacyIntegration, Device, Subscription, Plan, Report]

  config.model RibonConfig do
    field :default_ticket_value do
      label{ "default_ticket_value (ticket value in usdc cents (100 = one dollar))" }
    end

    field :default_chain_id do
      label{ "default_chain_id (default chain id, like polygon or mumbai)" }
    end

    field :contribution_fee_percentage do
      label{ "contribution_fee_percentage (percentage that goes to pay contribution fees (the rest is for tickets pay) (ex: 20% for fees, 80% for tickets pay on each contribution))" }
    end

    field :ribon_club_fee_percentage do
      label{ "ribon_club_fee_percentage (percentage from ribon club that goes to fee) (ex: 15.0 = 15%)" }
    end

    field :minimum_contribution_chargeable_fee_cents do
      label{ "minimum_contribution_chargeable_fee_cents (minimum fee to charge from a contribution in usdc cents (100 = one dollar))" }
    end

    field :disable_labeling do
      label{ "disable labeling of new contributions and donations" }
    end
  end

  config.model DonationBlockchainTransaction do
    include_all_fields

    field :transaction_hash do
      formatted_value do
        path = bindings[:object].transaction_link
        bindings[:view].link_to(bindings[:object].transaction_hash, path, target: "_blank")
      end
    end
  end

  config.model NonProfit do
    field :main_image do
      label{ "Cause Card Image" }
    end

    ## This is displayed as "support_image" on admin (as demanded by the team), 
    ## but we call it background_image on the model
    
    field :background_image do
      label{ "Support Image" }
    end

    field :logo do
      label{ "Logo" }
    end

    field :wallet_address do
      label{ "Wallet address" }
    end

    include_all_fields
  end

  config.model NonProfitImpact do
    field :usd_cents_to_one_impact_unit do
      label{ "USD cents to one impact unit (100 = one dollar)" }
    end

    include_all_fields
  end

  config.model User do
    field :email do
      label{ "Email" }
      help "(to delete, change this to: 'deleted+user_id+@ribon.io')"
    end
    
    include_all_fields
    
    field :deleted_at do
      label{ "Deleted at" }
      help '(change here if deleting)'
    end
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
