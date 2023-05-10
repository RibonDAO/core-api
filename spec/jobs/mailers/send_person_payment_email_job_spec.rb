require 'rails_helper'

RSpec.describe Mailers::SendPersonPaymentEmailJob, type: :job do
  describe '#perform' do
    subject(:job) { described_class }

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

    let(:non_profit) { create(:non_profit, :with_impact) }
    let(:cause) { create(:cause) }
    let(:normalizer_double) { instance_double(Impact::Normalizer) }

    before do
      allow(SendgridWebMailer).to receive(:send_email).and_return(OpenStruct.new({ deliver_later: nil }))
      allow(Impact::Normalizer).to receive(:new).and_return(normalizer_double)
      allow(normalizer_double).to receive(:normalize).and_return([1, 2, 3])
    end

    context 'when user has language pt-BR and offer is brl' do
      let(:user) { create(:user, language: 'pt-BR') }
      let(:customer) { create(:customer, user:) }
      let(:offer) { create(:offer, price_cents: 100, currency: :brl) }
      let!(:person_payment) do
        create(:person_payment, payer: customer, receiver: non_profit, offer:,
                                status: :processing)
      end

      context 'when it is a payment to a non_profit' do
        it 'calls the send email function with correct arguments' do
          job.perform_now(person_payment:)

          expect(SendgridWebMailer).to have_received(:send_email)
            .with({ receiver: user.email,
                    dynamic_template_data: {
                      direct_giving_value: 'R$ 1,00',
                      receiver_name: non_profit.name,
                      direct_giving_impact: [1, 2, 3].join(' ')
                    },
                    template_name: 'giving_success_non_profit_template_id',
                    language: user.language })
        end
      end

      context 'when it is a payment to a cause' do
        let!(:person_payment) do
          create(:person_payment, payer: customer, receiver: cause, offer:,
                                  status: :processing)
        end

        it 'calls the send email function with correct arguments' do
          job.perform_now(person_payment:)

          expect(SendgridWebMailer).to have_received(:send_email)
            .with({ receiver: user.email,
                    dynamic_template_data: {
                      direct_giving_value: 'R$ 1,00',
                      receiver_name: cause&.name_pt_br,
                      direct_giving_impact: 'R$ 0,20'
                    },
                    template_name: 'giving_success_cause_template_id',
                    language: user.language })
        end
      end
    end

    context 'when user has language en and offer is usd' do
      let(:user) { create(:user, language: 'en') }
      let(:customer) { create(:customer, user:) }
      let(:offer) { create(:offer, price_cents: 100, currency: :usd) }

      context 'when it is a payment to a non_profit' do
        let!(:person_payment) do
          create(:person_payment, payer: customer, receiver: non_profit,
                                  offer:, status: :processing)
        end

        it 'calls the send email function with correct arguments' do
          job.perform_now(person_payment:)

          expect(SendgridWebMailer).to have_received(:send_email)
            .with({ receiver: user.email,
                    dynamic_template_data: {
                      direct_giving_value: '$ 1.00',
                      receiver_name: non_profit.name,
                      direct_giving_impact: [1, 2, 3].join(' ')
                    },
                    template_name: 'giving_success_non_profit_template_id',
                    language: user.language })
        end
      end

      context 'when it is a payment to a cause' do
        let!(:person_payment) do
          create(:person_payment, payer: customer, receiver: cause,
                                  offer:, status: :processing)
        end

        it 'calls the send email function with correct arguments' do
          job.perform_now(person_payment:)

          expect(SendgridWebMailer).to have_received(:send_email)
            .with({ receiver: user.email,
                    dynamic_template_data: {
                      direct_giving_value: '$ 1.00',
                      receiver_name: cause&.name_en,
                      direct_giving_impact: '$ 0.20'
                    },
                    template_name: 'giving_success_cause_template_id',
                    language: user.language })
        end
      end
    end
  end
end
