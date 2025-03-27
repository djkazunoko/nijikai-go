# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  describe '#created_by?' do
    let(:post_owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:group) { create(:group) }
    let(:post) { create(:post, user: post_owner, group:) }

    context 'when the user is the owner of the post' do
      it 'returns true' do
        expect(post.created_by?(post_owner)).to be true
      end
    end

    context 'when the user is not the owner of the post' do
      it 'returns false' do
        expect(post.created_by?(other_user)).to be false
      end
    end

    context 'when the user is nil' do
      it 'returns false' do
        expect(post.created_by?(nil)).to be false
      end
    end
  end
end
