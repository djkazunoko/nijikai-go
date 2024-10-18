# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :system do
  let(:group) { create(:group) }
  let(:alice) { build(:user, :alice) }

  describe 'creating a post' do
    before do
      github_mock(alice)
    end

    it 'logs in and creates a post' do
      visit group_path(group)
      expect(page).to have_content 'まだ投稿はありません。'

      click_button 'サインアップ / ログインをして投稿を作成する'
      expect(page).to have_current_path(group_path(group))

      expect do
        fill_in 'post_content', with: 'テストコメント'
        click_button '投稿を作成する'
        expect(page).to have_content '投稿が作成されました'
        expect(page).to have_content 'テストコメント'
        within('.chat-header') do
          expect(page).to have_content(alice.name)
          expect(page).to have_content(I18n.l(Post.last.created_at, format: :short))
        end
        within('.chat-image') do
          expect(page).to have_link(href: "https://github.com/#{alice.name}")
          expect(page).to have_css("img[src='#{alice.image_url}']")
        end
        expect(page).not_to have_content 'まだ投稿はありません。'
      end.to change(Post, :count).by(1)

      expect(page).to have_current_path(group_path(group))
    end
  end

  describe 'deleting a post' do
    context 'when logged in as the post owner' do
      before do
        github_mock(alice)
        create(:post, user: alice, group:)
      end

      it 'deletes a post' do
        visit group_path(group)
        expect(page).to have_content 'MyText'
        within('.chat') do
          expect(page).not_to have_button '削除'
        end

        click_button 'サインアップ / ログインをして投稿を作成する'

        expect do
          accept_confirm do
            within('.chat') do
              click_button '削除'
            end
          end

          expect(page).to have_content '投稿が削除されました'
          expect(page).not_to have_content 'MyText'
        end.to change(Post, :count).by(-1)

        expect(page).to have_current_path(group_path(group))
      end
    end

    context 'when logged in as a non-post owner' do
      before do
        github_mock(group.owner)
        create(:post, user: alice, group:)
      end

      it 'does not show the delete button' do
        visit group_path(group)
        expect(page).to have_content 'MyText'

        click_button 'サインアップ / ログインをして投稿を作成する'

        within('.chat') do
          expect(page).not_to have_button '削除'
        end
      end
    end
  end
end
