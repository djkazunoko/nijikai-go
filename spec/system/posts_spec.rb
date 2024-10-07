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
      expect(page).to have_content 'まだコメントはありません。'

      click_button 'サインアップ / ログインをしてコメントを投稿する'
      expect(page).to have_current_path(group_path(group))

      expect do
        fill_in 'post_content', with: 'テストコメント'
        click_button 'コメントを投稿する'
        expect(page).to have_content '投稿が作成されました'
        expect(page).to have_content 'テストコメント'
        within('.chat-footer') do
          expect(page).to have_content(alice.name)
          expect(page).to have_content(I18n.l(Post.last.created_at, format: :short))
        end
        within('.chat-image') do
          expect(page).to have_link(href: "https://github.com/#{alice.name}")
          expect(page).to have_css("img[src='#{alice.image_url}']")
        end
        expect(page).not_to have_content 'まだコメントはありません。'
      end.to change(Post, :count).by(1)

      expect(page).to have_current_path(group_path(group))
    end
  end
end
