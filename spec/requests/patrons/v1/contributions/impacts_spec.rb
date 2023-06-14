require 'rails_helper'

RSpec.describe 'Patrons::V1::Contributions::Impacts', type: :request do
  describe 'GET /index' do
    subject(:request) { get "/patrons/v1/contributions/#{contribution.id}/impacts", headers: }

    let(:headers) { { 'Email' => patron.email } }
    let(:patron) { create(:big_donor) }
    let(:person_payment) { create(:person_payment, payer: patron) }
    let(:receiver) { create(:non_profit, :with_impact) }
    let(:contribution) { create(:contribution, person_payment:, receiver:) }

    it 'returns the contribution direct impact' do
      request

      expect_response_collection_to_have_keys(%w[non_profit total_amount_donated formatted_impact])
    end
  end
end
