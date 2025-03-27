# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:alice) { create(:user, :alice) }

  describe '.find_or_create_from_auth_hash!' do
    let(:auth_hash) do
      {
        provider: 'github',
        uid: '1111',
        info: {
          nickname: 'bob',
          image: 'https://example.com/bob.png'
        }
      }
    end

    context 'when user does not exist' do
      it 'creates a new user with the given auth hash' do
        expect do
          described_class.find_or_create_from_auth_hash!(auth_hash)
        end.to change(described_class, :count).by(1)
      end

      it 'returns the created user' do
        user = described_class.find_or_create_from_auth_hash!(auth_hash)
        expect(user).to have_attributes(
          provider: 'github',
          uid: '1111',
          name: 'bob',
          image_url: 'https://example.com/bob.png'
        )
      end
    end

    context 'when user with the same uid and provider already exists' do
      let!(:existing_user_with_same_uid_and_provider) { create(:user, :alice) }

      it 'does not create a new user' do
        expect do
          described_class.find_or_create_from_auth_hash!(auth_hash)
        end.not_to change(described_class, :count)
      end

      it 'returns the existing user' do
        user = described_class.find_or_create_from_auth_hash!(auth_hash)
        expect(user).to eq(existing_user_with_same_uid_and_provider)
      end
    end

    context 'when user with the same uid and different provider already exists' do
      before { create(:user, :alice, provider: 'twitter') }

      it 'creates a new user with the given auth hash' do
        expect do
          described_class.find_or_create_from_auth_hash!(auth_hash)
        end.to change(described_class, :count).by(1)
      end

      it 'returns the created user' do
        user = described_class.find_or_create_from_auth_hash!(auth_hash)
        expect(user).to have_attributes(
          provider: 'github',
          uid: '1111',
          name: 'bob',
          image_url: 'https://example.com/bob.png'
        )
      end
    end
  end
end
