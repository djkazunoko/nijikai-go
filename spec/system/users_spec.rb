# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :system do
  let(:user) { create(:user) }
  let(:group) { create(:group) }

  describe 'login' do
    context 'when authentication is successful' do
      before do
        github_mock(user)
      end

      it 'can login' do
        visit root_path
        expect(page).not_to have_css('.avatar')

        click_button 'サインアップ / ログイン'
        expect(page).to have_content 'ログインしました'
        expect(page).to have_current_path(root_path)
        expect(page).to have_css(".avatar img[src='#{user.image_url}']")
      end
    end

    context 'when authentication is failed' do
      before do
        github_invalid_mock
      end

      it 'can not login and redirect to root_path' do
        visit root_path
        expect(page).not_to have_css('.avatar')

        click_button 'サインアップ / ログイン'
        expect(page).to have_content 'ログインをキャンセルしました'
        expect(page).to have_current_path(root_path)
        expect(page).not_to have_css('.avatar')
      end
    end
  end

  describe 'logout' do
    before do
      login_as(user)
    end

    it 'can logout' do
      visit root_path
      expect(page).to have_css(".avatar img[src='#{user.image_url}']")

      find('.avatar').click
      click_button 'ログアウト'
      expect(page).to have_current_path(root_path)
      expect(page).to have_content 'ログアウトしました'
      expect(page).not_to have_css('.avatar')
    end
  end

  describe 'delete account' do
    context 'when no owned and participating groups exist' do
      before do
        login_as(user)
      end

      it 'can delete own account' do
        visit root_path
        expect(page).to have_css(".avatar img[src='#{user.image_url}']")

        find('.avatar').click
        expect do
          accept_confirm do
            click_button 'アカウント削除'
          end
          expect(page).to have_content 'アカウントが削除されました'
        end.to change(User, :count).by(-1)

        expect(page).to have_current_path(root_path)
        expect(page).not_to have_css('.avatar')
      end
    end

    context 'when owned groups exist' do
      before do
        login_as(group.owner)
      end

      it 'cannot delete own account' do
        visit root_path
        expect(page).to have_css(".avatar img[src='#{group.owner.image_url}']")

        find('.avatar').click
        expect do
          accept_confirm do
            click_button 'アカウント削除'
          end
          expect(page).to have_content '主催の2次会グループが存在するため、アカウントを削除できません'
        end.not_to change(User, :count)

        expect(page).to have_current_path(root_path)
        expect(page).to have_css(".avatar img[src='#{group.owner.image_url}']")
      end
    end

    context 'when participating groups exist' do
      before do
        login_as(user)
        create(:ticket, user:, group:)
      end

      it 'cannot delete own account' do
        visit root_path
        expect(page).to have_css(".avatar img[src='#{user.image_url}']")

        find('.avatar').click
        expect do
          accept_confirm do
            click_button 'アカウント削除'
          end
          expect(page).to have_content '参加中の2次会グループが存在するため、アカウントを削除できません'
        end.not_to change(User, :count)

        expect(page).to have_current_path(root_path)
        expect(page).to have_css(".avatar img[src='#{user.image_url}']")
      end
    end
  end
end
