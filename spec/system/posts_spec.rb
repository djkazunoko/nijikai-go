# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :system do
  let(:group) { create(:group) }
  let(:user) { create(:user) }

  describe 'show posts' do
    context 'when there are no posts' do
      it 'displays a no posts message' do
        visit group_path(group)
        expect(page).to have_content 'まだ投稿はありません。'
      end
    end

    context 'when there are posts' do
      let!(:posts) { create_list(:post, 2, group:) }
      let(:post) { posts.first }

      it 'displays a list of posts' do
        visit group_path(group)
        within all('.chat-header').first do
          expect(page).to have_content post.user.name
          expect(page).to have_content I18n.l(post.created_at, format: :short)
        end
        within all('.chat-image').first do
          expect(page).to have_link(href: "https://github.com/#{post.user.name}")
          expect(page).to have_css("img[src='#{post.user.image_url}']")
        end
        expect(page).to have_content post.content
        expect(page).to have_css('.chat-start', count: 2)
      end
    end

    context 'when user is logged in' do
      before do
        login_as(user)
      end

      it 'displays the post form' do
        visit group_path(group)
        expect(page).to have_field 'post_content'
        expect(page).to have_button '投稿を作成する'
      end
    end

    context 'when user is not logged in' do
      it 'displays a log in and create button' do
        visit group_path(group)
        expect(page).to have_button 'サインアップ / ログインをして投稿を作成する'
      end

      it 'does not display the delete button' do
        create(:post, group:)
        visit group_path(group)
        within('.chat') do
          expect(page).not_to have_button '削除'
        end
      end
    end

    context 'when user is the post owner' do
      let(:post) { create(:post, group:) }

      before do
        login_as(post.user)
      end

      it 'displays the delete button' do
        visit group_path(group)
        within('.chat') do
          expect(page).to have_button '削除'
        end
      end
    end

    context 'when user is not the post owner' do
      before do
        create(:post, group:)
        login_as(user)
      end

      it 'does not display the delete button' do
        visit group_path(group)
        within('.chat') do
          expect(page).not_to have_button '削除'
        end
      end
    end
  end

  describe 'creating a new post' do
    context 'with valid input' do
      before do
        github_mock(user)
      end

      it 'creates a post' do
        visit group_path(group)

        click_button 'サインアップ / ログインをして投稿を作成する'
        expect(page).to have_current_path(group_path(group))
        expect(page).to have_content 'まだ投稿はありません。'

        expect do
          fill_in 'post_content', with: 'テストコメント'
          click_button '投稿を作成する'
          expect(page).to have_content '投稿が作成されました'
          expect(page).to have_content 'テストコメント'
          expect(page).not_to have_content 'まだ投稿はありません。'
        end.to change(Post, :count).by(1)

        expect(page).to have_current_path(group_path(group))
      end
    end

    context 'with empty input' do
      before do
        login_as(user)
      end

      it 'does not create the post and displays an error message' do
        visit group_path(group)

        expect do
          click_button '投稿を作成する'
          expect(page).to have_content '投稿内容を入力してください'
        end.not_to change(Post, :count)

        expect(page).to have_current_path(group_path(group))
      end
    end

    context 'with more than 2000 characters' do
      before do
        login_as(user)
      end

      it 'does not create the post and displays an error message' do
        visit group_path(group)

        expect do
          fill_in 'post_content', with: 'a' * 2001
          click_button '投稿を作成する'
          expect(page).to have_content '投稿内容は2000文字以内で入力してください'
        end.not_to change(Post, :count)

        expect(page).to have_current_path(group_path(group))
      end
    end
  end

  describe 'deleting a post' do
    let(:post) { create(:post, group:) }

    before do
      login_as(post.user)
    end

    it 'deletes a post' do
      visit group_path(group)
      expect(page).to have_content post.content
      expect(page).not_to have_content 'まだ投稿はありません。'

      expect do
        accept_confirm do
          within('.chat') do
            click_button '削除'
          end
        end

        expect(page).to have_content '投稿が削除されました'
        expect(page).not_to have_content post.content
        expect(page).to have_content 'まだ投稿はありません。'
      end.to change(Post, :count).by(-1)

      expect(page).to have_current_path(group_path(group))
    end
  end
end
