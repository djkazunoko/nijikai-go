# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  include Turbo::Broadcastable::TestHelper

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

  describe 'broadcasts' do
    let(:group) { create(:group) }
    let(:other_group) { create(:group) }

    it 'broadcasts a created post only to its group' do
      group_stream = stream_name_from(group)
      other_group_stream = stream_name_from(other_group)

      expect { create(:post, group:) }
        .to change { broadcasts(group_stream).size }.by(1)
        .and change { broadcasts(other_group_stream).size }.by(0)
    end

    it 'broadcasts a removed post only to its group' do
      post = create(:post, group:)
      group_stream = stream_name_from(group)
      other_group_stream = stream_name_from(other_group)

      expect { post.destroy! }
        .to change { broadcasts(group_stream).size }.by(1)
        .and change { broadcasts(other_group_stream).size }.by(0)
    end
  end
end
