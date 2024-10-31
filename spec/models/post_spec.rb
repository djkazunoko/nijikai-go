# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_length_of(:content).is_at_most(2000) }
  end

  describe '#created_by?' do
    let(:alice) { create(:user, :alice) }
    let(:bob) { create(:user) }
    let(:group) { create(:group) }
    let(:post) { create(:post, user: alice, group:) }

    context 'when the user is the creator of the post' do
      it 'returns true' do
        expect(post.created_by?(alice)).to be true
      end
    end

    context 'when the user is not the creator of the post' do
      it 'returns false' do
        expect(post.created_by?(bob)).to be false
      end
    end

    context 'when the user is nil' do
      it 'returns false' do
        expect(post.created_by?(nil)).to be false
      end
    end
  end
end
