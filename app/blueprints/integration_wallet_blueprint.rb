class IntegrationWalletBlueprint < Blueprinter::Base
  identifier :id

  fields :public_key, :encrypted_private_key, :private_key_iv
end
