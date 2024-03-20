# frozen_string_literal: true

require 'rails_helper'

describe Users::CreateProfile do
  describe '.call' do
    include ActiveStorage::Blob::Analyzable
    let(:data) do
      OpenStruct.new(name: 'John', picture: 'https://picsum.photos/200/300')
    end
    let(:user) { create(:user) }
    let(:command) { described_class.call(data:, user:) }

    before do
      allow(URI).to receive(:parse).and_return(OpenStruct.new(
                                                 scheme: 'https',
                                                 host: 'picsum.photos',
                                                 open: File.open('vendor/assets/ribon_logo.png')
                                               ))
    end

    context 'when there is not an user profile yet' do
      it 'creates a userProfile' do
        expect { command }.to change(UserProfile, :count).by(1)
      end

      it 'sets name' do
        command
        expect(user.user_profile.name).to eq(data.name)
      end

      it 'sets photo' do
        command
        expect(user.user_profile.photo.attached?).to be(true)
      end
    end

    context 'when there is user profile' do
      let!(:user_profile) { create(:user_profile, :with_image, user:) }

      it 'do not create a userProfile' do
        expect { command }.to change(UserProfile, :count).by(0)
      end

      it 'will not change name' do
        expect { command }.not_to change(user_profile, :name)
      end

      it 'will not change photo' do
        expect { command }.not_to change(ActiveStorage::Attachment, :count)
      end
    end
  end
end
