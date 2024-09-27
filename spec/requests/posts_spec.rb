# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  let(:group) { create(:group) }
  let(:alice) { build(:user, :alice) }

  describe 'POST /groups/:id/posts' do
    context 'when user is a member of the group' do
      before do
        create(:ticket, group:, user: alice)
        github_mock(alice)
        login
      end

      it 'creates a post and redirects to the group page' do
        expect do
          post group_posts_path(group), params: { post: { content: 'test post' } }
        end.to change(Post, :count).by(1)

        expect(response).to redirect_to(group_path(group))
      end
    end

    context 'when user is not a member of the group' do
      before do
        github_mock(alice)
        login
      end

      it 'does not create a post and redirects to the group page with an error message' do
        expect do
          post group_posts_path(group), params: { post: { content: 'test post' } }
        end.not_to change(Post, :count)

        expect(response).to redirect_to(group_path(group))
        follow_redirect!
        expect(response.body).to include('このグループに参加していないため、投稿できません')
      end
    end

    context 'when user is the group owner' do
      before do
        github_mock(group.owner)
        login
      end

      it 'creates a post and redirects to the group page' do
        expect do
          post group_posts_path(group), params: { post: { content: 'test post' } }
        end.to change(Post, :count).by(1)

        expect(response).to redirect_to(group_path(group))
      end
    end

    context 'when user is not logged in' do
      it 'does not create a post and redirects to the root path' do
        expect do
          post group_posts_path(group), params: { post: { content: 'test post' } }
        end.not_to change(Post, :count)

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
