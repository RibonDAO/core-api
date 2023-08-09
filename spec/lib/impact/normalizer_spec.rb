require 'rails_helper'

RSpec.describe Impact::Normalizer do
  describe '#normalize' do
    subject(:method_call) { described_class.new(non_profit, rounded_impact).normalize }

    let(:non_profit) { create(:non_profit) }

    context 'when impact is based on time' do
      before do
        create(:non_profit_impact, non_profit:, measurement_unit: 'days_months_and_years',
                                   donor_recipient: 'person,people', impact_description: 'impact,impacts')
      end

      context 'when period is lower than 2 years' do
        let(:rounded_impact) { 540 }

        it 'returns the correct impact amount' do
          expect(method_call[0]).to eq '1 year, 5 months and 25 days'
        end

        it 'returns the correct impact description' do
          expect(method_call[1]).to eq 'of impacts for'
        end

        it 'returns the correct donor recipient' do
          expect(method_call[2]).to eq '1 person'
        end
      end

      context 'when period is higher than 2 years' do
        let(:rounded_impact) { 800 }

        it 'returns the correct impact amount' do
          expect(method_call[0]).to eq '1 year, 1 month and 5 days'
        end

        it 'returns the correct impact description' do
          expect(method_call[1]).to eq 'of impacts for'
        end

        it 'returns the correct donor recipient' do
          expect(method_call[2]).to eq '2 people'
        end
      end

      context 'when period is 1 day' do
        let(:rounded_impact) { 1 }

        it 'returns the correct impact amount' do
          expect(method_call[0]).to eq '1 day'
        end

        it 'returns the correct impact description' do
          expect(method_call[1]).to eq 'of impact for'
        end

        it 'returns the correct donor recipient' do
          expect(method_call[2]).to eq '1 person'
        end
      end

      context 'when period is 1 month' do
        let(:rounded_impact) { 30 }

        it 'returns the correct impact amount' do
          expect(method_call[0]).to eq '1 month'
        end

        it 'returns the correct impact description' do
          expect(method_call[1]).to eq 'of impacts for'
        end

        it 'returns the correct donor recipient' do
          expect(method_call[2]).to eq '1 person'
        end
      end

      context 'when period is 1 year' do
        let(:rounded_impact) { 365 }

        it 'returns the correct impact amount' do
          expect(method_call[0]).to eq '1 year'
        end

        it 'returns the correct impact description' do
          expect(method_call[1]).to eq 'of impacts for'
        end

        it 'returns the correct donor recipient' do
          expect(method_call[2]).to eq '1 person'
        end
      end

      context 'when period is 10 years' do
        let(:rounded_impact) { 3650 }

        it 'returns the correct impact amount' do
          expect(method_call[0]).to eq '2 years'
        end

        it 'returns the correct impact description' do
          expect(method_call[1]).to eq 'of impacts for'
        end

        it 'returns the correct donor recipient' do
          expect(method_call[2]).to eq '5 people'
        end
      end
    end

    context 'when impact is not based on time' do
      before do
        create(:non_profit_impact, non_profit:, measurement_unit: 'quantity_without_decimals',
                                   donor_recipient: 'person,people', impact_description: 'impact,impacts')
      end

      context 'when impact is lower than 200' do
        let(:rounded_impact) { 2 }

        it 'returns the correct impact amount' do
          expect(method_call[0]).to eq '2'
        end

        it 'returns the correct impact description' do
          expect(method_call[1]).to eq 'impacts for'
        end

        it 'returns the correct donor recipient' do
          expect(method_call[2]).to eq '1 person'
        end
      end

      context 'when impact is higher than 200' do
        let(:rounded_impact) { 400 }

        it 'returns the correct impact amount' do
          expect(method_call[0]).to eq '200'
        end

        it 'returns the correct impact description' do
          expect(method_call[1]).to eq 'impacts for'
        end

        it 'returns the correct donor recipient' do
          expect(method_call[2]).to eq '2 people'
        end
      end

      context 'when impact is 1' do
        let(:rounded_impact) { 1 }

        it 'returns the correct impact amount' do
          expect(method_call[0]).to eq '1'
        end

        it 'returns the correct impact description' do
          expect(method_call[1]).to eq 'impact for'
        end

        it 'returns the correct donor recipient' do
          expect(method_call[2]).to eq '1 person'
        end
      end
    end

    context 'when got some error' do
      before do
        create(:non_profit_impact, non_profit:, measurement_unit: 'days_months_and_years',
                                   donor_recipient: 'person,people', impact_description: 'impact,impacts')
      end

      context 'when rounded impact is zero' do
        let(:rounded_impact) { 0 }

        it 'raises an ImpactNormalizationError' do
          expect { method_call }.to raise_error(Exceptions::ImpactNormalizationError)
        end
      end

      context 'when rounded impact is nil or empty' do
        let(:rounded_impact) { nil }

        it 'raises an ImpactNormalizationError' do
          expect { method_call }.to raise_error(Exceptions::ImpactNormalizationError)
        end
      end
    end
  end
end
