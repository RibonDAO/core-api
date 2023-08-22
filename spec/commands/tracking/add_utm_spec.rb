require 'rails_helper'

describe Tracking::AddUtm do
  describe '.call' do
    subject(:command) do
      described_class.call(
        trackable: user,
        utm_params: {
          utm_source: 'source',
          utm_medium: 'medium',
          utm_campaign: 'campaign'
        }
      )
    end

    let(:user) { create(:user) }

    context 'when send all parameters correctly' do
      it 'expects to create a new utm' do
        expect { command }.to change(Utm, :count).by(1)
      end
    end

    context 'when trackable already has a utm' do
      before do
        create(:utm, trackable: user)
      end

      it 'expects not to create a new utm' do
        expect { command }.not_to change(Utm, :count)
      end
    end

    context 'when does not send all parameters correctly' do
      it 'expects not to create a new utm' do
        expect do
          described_class.call(
            trackable: create(:user),
            utm_params: {
              utm_source: nil,
              utm_medium: nil,
              utm_campaign: nil
            }
          )
        end.not_to change(Utm, :count)
      end
    end
  end
end
