# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :system do
  let(:group) { create(:group) }
  let(:user) { create(:user) }

  describe 'show posts' do
    context 'when there are posts' do
      let!(:posts) { create_list(:post, 2, group:) }
      let(:post) { posts.first }

      it 'displays a list of posts' do
        visit group_path(group)
        within all('.post').first do
          expect(page).to have_css("img[src='#{post.user.image_url}']")
          expect(page).to have_link(post.user.name, href: "https://github.com/#{post.user.name}")
          expect(page).to have_content I18n.l(post.created_at, format: :short)
          expect(page).to have_content post.content
        end
        expect(page).to have_css('.post', count: 2)
      end
    end

    context 'when user is logged in' do
      before do
        login_as(user)
      end

      it 'displays the post form' do
        visit group_path(group)
        expect(page).to have_field 'post_content'
        expect(page).to have_button 'コメントする'
      end
    end

    context 'when user is not logged in' do
      it 'displays a log in and create button' do
        visit group_path(group)
        expect(page).to have_button 'ログインをしてコメントする'
      end

      it 'does not display the delete button' do
        create(:post, group:)
        visit group_path(group)
        within('.post') do
          expect(page).not_to have_button '削除する'
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
        within('.post') do
          expect(page).to have_button '削除する'
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
        within('.post') do
          expect(page).not_to have_button '削除する'
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

        click_button 'ログインをしてコメントする'
        expect(page).to have_current_path(group_path(group))

        expect do
          fill_in 'post_content', with: 'テストコメント'
          click_button 'コメントする'
          expect(page).to have_content 'コメントが作成されました。'
          expect(page).to have_content 'テストコメント'
          within('.post') do
            expect(page).to have_button '削除する'
          end
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
          click_button 'コメントする'
          expect(page).to have_content 'コメントを入力してください'
        end.not_to change(Post, :count)

        expect(page).to have_current_path(group_path(group))
      end
    end

    context 'with more than 1000 characters' do
      before do
        login_as(user)
      end

      it 'does not create the post and displays an error message' do
        visit group_path(group)

        expect do
          fill_in 'post_content', with: 'a' * 2001
          click_button 'コメントする'
          expect(page).to have_content 'コメントは1000文字以内で入力してください'
        end.not_to change(Post, :count)

        expect(page).to have_current_path(group_path(group))
      end
    end

    context 'when creating a post' do
      it 'display the creates post and does not display the post delete button in a different session' do
        visit group_path(group)

        using_session('post creator session') do
          login_as(user)
          visit group_path(group)
          fill_in 'post_content', with: 'テストコメント'
          click_button 'コメントする'
        end

        # reverts to different session
        expect(page).to have_content 'テストコメント'
        expect(page).not_to have_content 'コメントが作成されました。'
        within('.post') do
          expect(page).not_to have_button '削除する'
        end
      end
    end
  end

  describe 'deleting a post' do
    let(:post) { create(:post, group:) }

    context 'when post owner deletes a post' do
      it 'deletes a post' do
        login_as(post.user)
        visit group_path(group)
        expect(page).to have_content post.content

        expect do
          accept_confirm do
            within('.post') do
              click_button '削除する'
            end
          end

          expect(page).to have_content 'コメントが削除されました。'
          expect(page).not_to have_content post.content
        end.to change(Post, :count).by(-1)

        expect(page).to have_current_path(group_path(group))
      end

      it 'does not display the deleted post in a different session' do
        visit group_path(group)
        expect(page).to have_content post.content

        using_session('post owner session') do
          login_as(post.user)
          visit group_path(group)
          accept_confirm do
            within('.post') do
              click_button '削除する'
            end
          end
        end

        # reverts to different session
        expect(page).not_to have_content post.content
        expect(page).not_to have_content 'コメントが削除されました。'
      end
    end
  end
end
