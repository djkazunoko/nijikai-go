# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.create(:user) }

  it 'is valid with all attributes' do
    expect(user).to be_valid
  end

  describe 'validations' do
    it 'is invalid without a provider' do
      user.provider = nil
      user.valid?
      expect(user.errors[:provider]).to include('を入力してください')
    end

    it 'is invalid without a uid' do
      user.uid = nil
      user.valid?
      expect(user.errors[:uid]).to include('を入力してください')
    end

    it 'is invalid without a name' do
      user.name = nil
      user.valid?
      expect(user.errors[:name]).to include('を入力してください')
    end

    it 'is invalid without an image_url' do
      user.image_url = nil
      user.valid?
      expect(user.errors[:image_url]).to include('を入力してください')
    end

    it 'is invalid with a duplicate name' do
      FactoryBot.create(:user)
      user2 = FactoryBot.build(:user, image_url: 'https://example.com/bob.png', provider: 'twitter', uid: '0002')
      user2.valid?
      expect(user2.errors[:name]).to include('はすでに存在します')
    end

    it 'is invalid with a duplicate image_url' do
      FactoryBot.create(:user)
      user2 = FactoryBot.build(:user, name: 'bob', provider: 'twitter', uid: '0002')
      user2.valid?
      expect(user2.errors[:image_url]).to include('はすでに存在します')
    end

    it 'is invalid with a duplicate uid and provider pair' do
      FactoryBot.create(:user)
      user2 = FactoryBot.build(:user, name: 'bob', image_url: 'https://example.com/bob.png')
      user2.valid?
      expect(user2.errors[:uid]).to include('はすでに存在します')
    end

    it 'allows duplicate uid with different provider' do
      FactoryBot.create(:user)
      user2 = FactoryBot.build(:user, name: 'bob', image_url: 'https://example.com/bob.png', provider: 'twitter')
      expect(user2).to be_valid
    end
  end

  describe '.find_or_create_from_auth_hash!' do
    let(:auth_hash) do
      {
        provider: 'github',
        uid: '0001',
        info: {
          nickname: 'alice',
          image: 'https://example.com/alice.png'
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
          uid: '0001',
          name: 'alice',
          image_url: 'https://example.com/alice.png'
        )
      end
    end

    context 'when user already exists' do
      before { FactoryBot.create(:user) }

      it 'does not create a new user' do
        expect do
          described_class.find_or_create_from_auth_hash!(auth_hash)
        end.not_to change(described_class, :count)
      end

      it 'returns the existing user' do
        user = described_class.find_or_create_from_auth_hash!(auth_hash)
        expect(user).to have_attributes(
          provider: 'github',
          uid: '0001',
          name: 'alice',
          image_url: 'https://example.com/alice.png'
        )
      end
    end
  end
end
