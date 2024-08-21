# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:alice) { create(:user, :alice) }

  it 'is valid with all attributes' do
    expect(alice).to be_valid
  end

  describe 'validations' do
    it 'is invalid without a provider' do
      alice.provider = nil
      alice.valid?
      expect(alice.errors[:provider]).to include('を入力してください')
    end

    it 'is invalid without a uid' do
      alice.uid = nil
      alice.valid?
      expect(alice.errors[:uid]).to include('を入力してください')
    end

    it 'is invalid without a name' do
      alice.name = nil
      alice.valid?
      expect(alice.errors[:name]).to include('を入力してください')
    end

    it 'is invalid without an image_url' do
      alice.image_url = nil
      alice.valid?
      expect(alice.errors[:image_url]).to include('を入力してください')
    end

    it 'is invalid with a duplicate name' do
      create(:user, :alice)
      user2 = build(:user, name: 'alice')
      user2.valid?
      expect(user2.errors[:name]).to include('はすでに存在します')
    end

    it 'is invalid with a duplicate image_url' do
      create(:user, :alice)
      user2 = build(:user, image_url: 'https://example.com/alice.png')
      user2.valid?
      expect(user2.errors[:image_url]).to include('はすでに存在します')
    end

    it 'is invalid with a duplicate uid and provider pair' do
      create(:user, :alice)
      user2 = build(:user, uid: '1111')
      user2.valid?
      expect(user2.errors[:uid]).to include('はすでに存在します')
    end

    it 'allows duplicate uid with different provider' do
      create(:user, :alice)
      user2 = build(:user, provider: 'twitter', uid: '1111')
      expect(user2).to be_valid
    end
  end

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
      it 'creates a new user' do
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

    context 'when user with the same uid and provider pair already exists' do
      before { create(:user, :alice) }

      it 'does not create a new user' do
        expect do
          described_class.find_or_create_from_auth_hash!(auth_hash)
        end.not_to change(described_class, :count)
      end

      it 'returns the existing user' do
        user = described_class.find_or_create_from_auth_hash!(auth_hash)
        expect(user).to have_attributes(
          provider: 'github',
          uid: '1111',
          name: 'alice',
          image_url: 'https://example.com/alice.png'
        )
      end
    end
  end
end
