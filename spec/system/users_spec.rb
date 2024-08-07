# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :system do
  describe 'login' do
    context 'when authentication is successful' do
      before do
        github_mock(FactoryBot.build(:user))
      end

      it 'can login' do
        visit root_path
        expect(page).to have_content 'GitHubアカウントが必要です'
        expect(page).not_to have_css('.avatar img[src="https://example.com/alice.png"]')

        expect do
          click_button 'サインアップ / ログインをして2次会グループを作成'

          expect(page).to have_content 'ログインしました'
        end.to change(User, :count).by(1)

        expect(page).to have_current_path(new_group_path)
        expect(page).to have_css('.avatar img[src="https://example.com/alice.png"]')
      end
    end

    context 'when authentication is failed' do
      before do
        github_invalid_mock
      end

      it 'redirects to root_path' do
        visit root_path
        expect(page).to have_content 'GitHubアカウントが必要です'
        expect(page).not_to have_css('.avatar img[src="https://example.com/alice.png"]')

        expect do
          click_button 'サインアップ / ログインをして2次会グループを作成'

          expect(page).to have_content 'ログインをキャンセルしました'
        end.not_to change(User, :count)

        expect(page).to have_current_path(root_path)
        expect(page).not_to have_css('.avatar img[src="https://example.com/alice.png"]')
      end
    end
  end

  describe 'logout' do
    before do
      github_mock(FactoryBot.build(:user))
    end

    it 'can logout' do
      visit root_path
      expect(page).to have_content 'GitHubアカウントが必要です'
      expect(page).not_to have_css('.avatar img[src="https://example.com/alice.png"]')

      click_button 'サインアップ / ログインをして2次会グループを作成'
      expect(page).to have_current_path(new_group_path)
      expect(page).to have_css('.avatar img[src="https://example.com/alice.png"]')

      find('.avatar').click
      click_button 'ログアウト'
      expect(page).to have_current_path(root_path)
      expect(page).to have_content 'ログアウトしました'
      expect(page).to have_content 'GitHubアカウントが必要です'
      expect(page).not_to have_css('.avatar img[src="https://example.com/alice.png"]')
    end
  end

  describe 'delete account' do
    context 'when no hosted groups exist' do
      before do
        github_mock(FactoryBot.build(:user))
      end

      it 'can delete own account' do
        visit root_path
        click_button 'サインアップ / ログインをして2次会グループを作成'
        expect(page).to have_current_path(new_group_path)
        expect(page).to have_css('.avatar img[src="https://example.com/alice.png"]')

        find('.avatar').click
        expect do
          accept_confirm do
            click_button 'アカウント削除'
          end
          expect(page).to have_current_path(root_path)
          expect(page).to have_content 'アカウントが削除されました'
          expect(page).not_to have_css('.avatar img[src="https://example.com/alice.png"]')
        end.to change(User, :count).by(-1)
      end
    end

    context 'when hosted groups exist' do
      before do
        group = FactoryBot.create(:group)
        github_mock(group.owner)
      end

      it 'cannot delete own account' do
        visit root_path
        click_button 'サインアップ / ログインをして2次会グループを作成'
        expect(page).to have_current_path(new_group_path)
        expect(page).to have_css('.avatar img[src="https://example.com/alice.png"]')

        find('.avatar').click
        expect do
          accept_confirm do
            click_button 'アカウント削除'
          end
          expect(page).to have_current_path(root_path)
          expect(page).to have_content '主催の2次会グループが存在するため、アカウントを削除できません'
          expect(page).to have_css('.avatar img[src="https://example.com/alice.png"]')
        end.not_to change(User, :count)
      end
    end
  end
end
