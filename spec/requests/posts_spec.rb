# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  let(:group) { create(:group) }
  let(:user) { create(:user) }

  describe 'POST /groups/:id/posts' do
    context 'with valid input' do
      before do
        login_as(user)
      end

      it 'creates a post and redirects to the group page' do
        expect do
          post group_posts_path(group), params: { post: { content: 'test post' } }
        end.to change(Post, :count).by(1)

        expect(response).to redirect_to(group_path(group))
      end
    end

    context 'with empty input' do
      before do
        login_as(user)
      end

      it 'does not create the post and redirects to the group page' do
        expect do
          post group_posts_path(group), params: { post: { content: '' } }
        end.not_to change(Post, :count)

        expect(response).to redirect_to(group_path(group))
      end
    end

    context 'with more than 2000 characters' do
      before do
        login_as(user)
      end

      it 'does not create the post and redirects to the group page' do
        expect do
          post group_posts_path(group), params: { post: { content: 'a' * 2001 } }
        end.not_to change(Post, :count)

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

    context 'with a Turbo Streams request' do
      before do
        login_as(user)
      end

      it 'creates a post and returns Turbo Streams responses' do
        expect do
          post group_posts_path(group), params: { post: { content: 'test post' } }, as: :turbo_stream
        end.to change(Post, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq Mime[:turbo_stream]
        assert_turbo_stream action: 'replace', target: 'new_post'
        assert_turbo_stream action: 'prepend', target: 'flash'

        turbo_streams_posts = capture_turbo_stream_broadcasts 'posts'
        expect(turbo_streams_posts.first['action']).to eq('append')
        expect(turbo_streams_posts.first['target']).to eq('posts')

        turbo_streams_user = capture_turbo_stream_broadcasts user
        expect(turbo_streams_user.first['action']).to eq('append')
        expect(turbo_streams_user.first['target']).to eq("delete_button_#{Post.last.id}")
      end
    end
  end

  describe 'DELETE /groups/:id/posts/:id' do
    let!(:post) { create(:post, group:) }

    context 'when logged in as the post owner' do
      before do
        login_as(post.user)
      end

      it 'deletes a post and redirects to the group page' do
        expect do
          delete group_post_path(group, post)
        end.to change(Post, :count).by(-1)

        expect(response).to redirect_to(group_path(group))
      end
    end

    context 'when logged in as a non-post owner' do
      before do
        login_as(user)
      end

      it 'does not delete the post and returns a 404 response' do
        expect do
          delete group_post_path(group, post)
        end.not_to change(Post, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not logged in' do
      it 'does not delete the post and redirects to the root path' do
        expect do
          delete group_post_path(group, post)
        end.not_to change(Post, :count)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with a Turbo Streams request' do
      before do
        login_as(post.user)
      end

      it 'deletes a post and returns Turbo Streams responses' do
        expect do
          delete group_post_path(group, post), as: :turbo_stream
        end.to change(Post, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq Mime[:turbo_stream]
        assert_turbo_stream action: 'prepend', target: 'flash'

        turbo_streams = capture_turbo_stream_broadcasts 'posts'
        expect(turbo_streams.second['action']).to eq('remove')
        expect(turbo_streams.second['target']).to eq("post_#{post.id}")
      end
    end
  end
end
