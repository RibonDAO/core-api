module Graphql
  module Queries
    module FetchDonationBalances
      Query = Graphql::RibonApi::Client.parse <<-'GRAPHQL'
        query {
          donationBalances {
            id
            integrationController{
              id
            }
            totalDonated
            nonProfit{
              id
            }
          }
        }
      GRAPHQL
    end
  end
end
