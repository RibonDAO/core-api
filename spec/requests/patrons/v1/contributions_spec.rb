require 'rails_helper'

RSpec.describe 'Patrons::V1::Contributions', type: :request do
  describe 'GET /index' do
    include_context 'when making a patron request' do
      let(:request) { get '/patrons/v1/contributions', headers: }
    end

    let(:offer) { create(:offer, currency: :usd) }

    before do
      person_payment = create(:person_payment, payer: patron, offer:)
      create(:contribution, person_payment:)
    end

    it 'returns a list of contributions for the patron' do
      request

      expect_response_collection_to_have_keys(%w[created_at id label
                                                 updated_at person_payment generated_fee_cents
                                                 liquid_value_cents usd_value_cents
                                                 contribution_balance stats])
    end
  end
end
