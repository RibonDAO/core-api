class ChainBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :ribon_contract_address, :donation_token_contract_address, :chain_id,
         :rpc_url, :symbol_name, :currency_name, :block_explorer_url,
         :default_donation_pool_address

  field(:node_url) do |object|
    EncryptionHelper.encrypt_string(object.node_url,
                                    RibonCoreApi.config[:web3][:node_url][:encryption_key],
                                    RibonCoreApi.config[:web3][:node_url][:encryption_iv])
  end
end
