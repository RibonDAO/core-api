require 'rails_helper'

RSpec.describe 'Api::V1::PersonPayments', type: :request do
  describe 'GET /index' do
    subject(:request) { get '/api/v1/person_payments' }

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

    before do
      create_list(:person_payment, 2, status: :paid)
      allow(Currency::Converters).to receive(:convert_to_usd).and_return(1)
    end

    it 'returns a list of person_payments' do
      request

      expect_response_collection_to_have_keys(%w[amount_cents crypto_amount external_id id
                                                 offer page paid_date payment_method
                                                 payer payer_identification service_fees
                                                 status total_items total_pages])
    end
  end

  describe 'GET find_by_person' do
    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

    before do
      allow(Currency::Converters).to receive(:convert_to_usd).and_return(1)
    end

    context 'when receiver is a cause' do
      let(:receiver) { create(:cause) }

      context 'when person is a customer' do
        subject(:request) { get "/api/v1/person_payments/cause/?email=#{unique_identifier}" }

        let!(:email) { 'dummyemail@ribon.io' }
        let(:unique_identifier) { Base64.strict_encode64(email) }
        let!(:customer) { create(:customer, email:) }

        it 'returns a list of person_payments' do
          create_list(:person_payment, 4, status: :paid, payer: customer, receiver:)
          request

          expect(response_json.count).to eq(4)

          expect_response_collection_to_have_keys(%w[amount_cents crypto_amount external_id id
                                                     offer page paid_date payment_method
                                                     payer payer_identification receiver
                                                     service_fees status total_items total_pages])
        end
      end

      context 'when person is a crypto_user' do
        subject(:request) { get "/api/v1/person_payments/cause/?wallet_address=#{unique_identifier}" }

        let!(:wallet_address) { '0xA222222222222222222222222222222222222222' }
        let(:unique_identifier) { Base64.strict_encode64(wallet_address) }
        let!(:crypto_user) { create(:crypto_user, wallet_address:) }

        it 'returns a list of person_payments' do
          create_list(:person_payment, 4, status: :paid, payer: crypto_user, receiver:)
          request

          expect(response_json.count).to eq(4)

          expect_response_collection_to_have_keys(%w[amount_cents crypto_amount external_id id
                                                     offer page paid_date payment_method
                                                     payer payer_identification receiver
                                                     service_fees status total_items total_pages])
        end
      end

      context 'when person is a customer AND a crypto_user' do
        subject(:request) do
          get "/api/v1/person_payments/cause/?email=#{encoded_email}&wallet_address=#{encoded_wallet_address}"
        end

        let!(:wallet_address) { '0xA222222222222222222222222222222222222222' }
        let!(:email)          { 'dummyemail@ribon.io' }

        let!(:encoded_wallet_address) { Base64.strict_encode64(wallet_address) }
        let!(:encoded_email)          { Base64.strict_encode64(email) }

        let!(:crypto_user) { create(:crypto_user, wallet_address:) }
        let!(:customer) { create(:customer, email:) }

        it 'returns a list of person_payments' do
          create_list(:person_payment, 4, status: :paid, payer: crypto_user, receiver:)
          create_list(:person_payment, 4, status: :paid, payer: customer, receiver:)

          request

          expect(response_json.count).to eq(8)

          expect_response_collection_to_have_keys(%w[amount_cents crypto_amount external_id id
                                                     offer page paid_date payment_method
                                                     payer payer_identification receiver
                                                     service_fees status total_items total_pages])
        end
      end
    end

    context 'when receiver is a NonProfit' do
      let(:receiver) { create(:non_profit) }

      context 'when person is a customer' do
        subject(:request) { get "/api/v1/person_payments/non_profit/?email=#{unique_identifier}" }

        let!(:email) { 'dummyemail@ribon.io' }
        let(:unique_identifier) { Base64.strict_encode64(email) }
        let!(:customer) { create(:customer, email:) }

        it 'returns a list of person_payments' do
          create_list(:person_payment, 4, status: :paid, payer: customer, receiver:)
          request

          expect(response_json.count).to eq(4)

          expect_response_collection_to_have_keys(%w[amount_cents crypto_amount external_id id
                                                     offer page paid_date payment_method
                                                     payer payer_identification receiver
                                                     service_fees status total_items total_pages])
        end
      end

      context 'when person is a crypto_user' do
        subject(:request) { get "/api/v1/person_payments/non_profit?wallet_address=#{unique_identifier}" }

        let!(:wallet_address) { '0xA222222222222222222222222222222222222222' }
        let(:unique_identifier) { Base64.strict_encode64(wallet_address) }
        let!(:crypto_user) { create(:crypto_user, wallet_address:) }

        it 'returns a list of person_payments' do
          create_list(:person_payment, 4, status: :paid, payer: crypto_user, receiver:)
          request

          expect(response_json.count).to eq(4)

          expect_response_collection_to_have_keys(%w[amount_cents crypto_amount external_id id
                                                     offer page paid_date payment_method
                                                     payer payer_identification receiver
                                                     service_fees status total_items total_pages])
        end
      end

      context 'when person is a customer AND a crypto_user' do
        subject(:request) do
          get "/api/v1/person_payments/non_profit?email=#{encoded_email}&wallet_address=#{encoded_wallet_address}"
        end

        let!(:wallet_address) { '0xA222222222222222222222222222222222222222' }
        let!(:email)          { 'dummyemail@ribon.io' }

        let!(:encoded_wallet_address) { Base64.strict_encode64(wallet_address) }
        let!(:encoded_email)          { Base64.strict_encode64(email) }

        let!(:crypto_user) { create(:crypto_user, wallet_address:) }
        let!(:customer) { create(:customer, email:) }

        it 'returns a list of the paid person_payments' do
          create_list(:person_payment, 4, status: :paid, payer: crypto_user, receiver:)
          create_list(:person_payment, 4, payer: customer, receiver:)

          request

          expect(response_json.count).to eq(4)

          expect_response_collection_to_have_keys(%w[amount_cents crypto_amount external_id id
                                                     offer page paid_date payment_method
                                                     payer payer_identification receiver
                                                     service_fees status total_items total_pages])
        end
      end
    end

    context 'when has pagination' do
      subject(:request) { get "/api/v1/person_payments/non_profit/?email=#{unique_identifier}&page=1&per=3" }

      let!(:email) { 'dummyemail@ribon.io' }
      let(:unique_identifier) { Base64.strict_encode64(email) }
      let!(:customer) { create(:customer, email:) }
      let(:receiver) { create(:non_profit) }

      it 'returns a list of person_payments' do
        create_list(:person_payment, 9, status: :paid, payer: customer, receiver:)
        request

        expect(response_json.count).to eq(3)

        expect_response_collection_to_have_keys(%w[amount_cents crypto_amount external_id id
                                                   offer page paid_date payment_method
                                                   payer payer_identification receiver
                                                   service_fees status total_items total_pages])
      end
    end
  end
end
