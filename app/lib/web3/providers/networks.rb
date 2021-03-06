module Web3
  module Providers
    class Networks
      config = RibonCoreApi.config[:web3][:networks]

      MUMBAI = {
        chain_name: 'Mumbai Testnet',
        ribon_contract_address: '0xD3850333819fBdd43784498F67010E5c87a2EAb3',
        donation_token_contract_address: '0x21A72dc641c8e5f13717a7e087d6D63B4f9A3574',
        chain_id: 0x13881,
        rpc_url: config[:mumbai][:rpc_url],
        node_url: config[:mumbai][:node_url],
        symbol_name: 'MATIC',
        currency_name: 'Matic',
        block_explorer_url: config[:mumbai][:block_explorer_url]
      }.freeze
      LOCAL = {
        chain_name: 'Localhost 8545',
        ribon_contract_address: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
        donation_token_contract_address: '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',
        chain_id: 0x539,
        rpc_url: 'http://localhost:8545',
        node_url: 'http://localhost:8545',
        symbol_name: 'ETH',
        currency_name: 'Ether',
        block_explorer_url: 'http://localhost:8545'
      }.freeze
    end
  end
end
