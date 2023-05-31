require 'rails_helper'

RSpec.describe 'Patrons::V1::Contributions', type: :request do
  describe 'GET /index' do
    subject(:request) { get '/patrons/v1/contributions', headers: }

    let(:headers) { { 'Email' => patron.email } }
    let(:patron) { create(:big_donor) }
    let(:offer) { create(:offer, currency: :usd) }

    before do
      person_payment = create(:person_payment, payer: patron, offer:)
      create(:contribution, person_payment:)
    end

    it 'returns a list of contributions for the patron' do
      request

      expect_response_collection_to_have_keys(%w[created_at id
                                                 updated_at person_payment generated_fee_cents
                                                 liquid_value_cents usd_value_cents
                                                 contribution_balance])
    end
  end
end
