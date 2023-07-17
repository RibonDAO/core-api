require 'rails_helper'

RSpec.describe 'Api::V1::Users::Contributions', type: :request do
  describe 'GET /index' do
    subject(:request) { get "/api/v1/users/#{user.id}/contributions" }

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

    let(:user) { create(:user) }
    let(:customer) { create(:customer, user:) }
    let!(:person_payment) { create(:person_payment, payer: customer, status: :paid) }
    let(:receiver) { create(:cause) }

    before { create(:contribution, person_payment:, receiver:) }

    it 'returns all user contributions' do
      request
      expect_response_collection_to_have_keys(%w[contribution_balance created_at generated_fee_cents id
                                                 label liquid_value_cents person_payment receiver
                                                 updated_at usd_value_cents])
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/api/v1/users/#{user.id}/contributions/#{contribution.id}" }

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_multiple_rates' } }

    let(:user) { create(:user) }
    let(:customer) { create(:customer, user:) }
    let!(:person_payment) { create(:person_payment, payer: customer, status: :paid) }
    let(:receiver) { create(:non_profit, :with_impact) }
    let!(:contribution) { create(:contribution, person_payment:, receiver:) }

    it 'returns the specified contribution' do
      request
      expect_response_to_have_keys(%w[contribution_balance created_at generated_fee_cents id
                                      label liquid_value_cents person_payment receiver
                                      updated_at usd_value_cents stats])
    end
  end
end
