module Graphql
  module Queries
    module FetchIntegrations
      Query = Graphql::RibonApi::Client.parse <<-'GRAPHQL'
        query {
          integrationControllers {
            id
            balance
          }
        }
      GRAPHQL
    end
  end
end
