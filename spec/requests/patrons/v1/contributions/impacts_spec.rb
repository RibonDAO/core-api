require 'rails_helper'

RSpec.describe 'Patrons::V1::Contributions::Impacts', type: :request do
  describe 'GET /index' do
    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_usd_brl' } }

    include_context 'when making a patron request' do
      let(:request) { get "/patrons/v1/contributions/#{contribution.id}/impacts", headers: }
    end

    let(:person_payment) { create(:person_payment, payer: patron) }
    let(:receiver) { create(:non_profit, :with_impact) }
    let(:contribution) { create(:contribution, person_payment:, receiver:) }

    before do
      create(:donation_contribution, contribution:, donation: create(:donation, non_profit: receiver))
    end

    it 'returns the contribution direct impact' do
      request

      expect_response_collection_to_have_keys(%w[non_profit total_amount_donated formatted_impact])
    end
  end
end
