class IntegrationBlueprint < Blueprinter::Base
  identifier :id

  fields :updated_at, :created_at, :name, :unique_address, :status, :integration_address

  association :integration_wallet, blueprint: IntegrationWalletBlueprint
end
