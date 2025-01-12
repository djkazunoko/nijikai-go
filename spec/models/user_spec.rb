# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:alice) { create(:user, :alice) }

  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:image_url) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_uniqueness_of(:image_url) }
    it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:provider).ignoring_case_sensitivity }
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
